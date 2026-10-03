import yt_dlp
from typing import Dict, Any, List

from app.providers.base import ImportProvider


class YoutubeProvider(ImportProvider):
    def __init__(self):
        self.ydl_opts = {
            'quiet': True,
            'skip_download': True,
            'no_warnings': True,
            'extract_flat': False
        }

    def validate_url(self, url: str) -> bool:
        return "v=" in url or "list=" in url or "youtu.be/" in url

    def extract_track(self, url: str) -> Dict[str, Any]:
        try:
            with yt_dlp.YoutubeDL(self.ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)

                return self._format_track_data(info)
        except Exception as e:
            raise ValueError(f"Error while extracting track: {str(e)}")

    def extract_playlist(self, url: str) -> Dict[str, Any]:
        opts = self.ydl_opts.copy()
        opts["extract_flat"] = True
        opts["ignoreerrors"] = True

        try:
            with yt_dlp.YoutubeDL(opts) as ydl:
                playlist_info = ydl.extract_info(url, download=False)

                if not playlist_info or "entries" not in playlist_info:
                    raise ValueError("Não foi possível extrair os dados da playlist.")

                tracks = []
                for track in playlist_info.get("entries", []):
                    if not track or not isinstance(track, dict):
                        continue
                    
                    title = track.get("title", "")
                    track_id = track.get("id")
                    availability = track.get("availability")
                    
                    if not title or not track_id:
                        continue
                    if title in ["[Private video]", "[Deleted video]", "[Unavailable video]"]:
                        continue
                    if "private" in title.lower() or "deleted" in title.lower() or "unavailable" in title.lower():
                        continue
                    if availability in ["private", "subscriber_only", "needs_auth", "unlisted_only"]:
                        continue

                    formatted_track = self._format_track_data(track)
                    if formatted_track:
                        tracks.append(formatted_track)

                cover_url = self._extract_thumbnail(playlist_info) or (tracks[0].get("thumbnail_url") if tracks else None)

                return {
                    "name": playlist_info.get("title") or "Playlist sem nome",
                    "description": playlist_info.get("description") or "",
                    "cover_url": cover_url,
                    "tracks": tracks,
                }

        except Exception as e:
            raise ValueError(f"Error while extracting playlist: {str(e)}")

    @staticmethod
    def _extract_thumbnail(data: Dict[str, Any]) -> str | None:
        thumbnail_url = data.get("thumbnail")
        if not thumbnail_url and data.get("thumbnails"):
            thumbnails = data.get("thumbnails")
            if isinstance(thumbnails, list) and len(thumbnails) > 0:
                thumbnail_url = thumbnails[-1].get("url")

        if not thumbnail_url and data.get("id"):
            thumbnail_url = f"https://i.ytimg.com/vi/{data.get('id')}/hqdefault.jpg"

        return thumbnail_url

    @classmethod
    def _format_track_data(cls, data: Dict) -> Dict[str, Any]:
        return {
            "id": data.get("id"),
            "title": data.get("title"),
            "artist": data.get("channel") or data.get("uploader"),
            "duration": data.get("duration"),
            "thumbnail_url": cls._extract_thumbnail(data),
            "source_url": "youtube",
            "url": data.get("webpage_url") or f"https://www.youtube.com/watch?v={data.get('id')}",
            "download_info": {
                "extractor": data.get("extractor"),
            }
        }