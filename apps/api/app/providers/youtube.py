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

    def extract_playlist(self, url: str) -> List[Dict[str, Any]]:
        opts = self.ydl_opts.copy()
        opts["extract_flat"] = True
        tracks = []

        try:
            with yt_dlp.YoutubeDL(opts) as ydl:
                playlist_info = ydl.extract_info(url, download=False)

                if not "entries" in playlist_info:
                    raise ValueError(f"Error while extracting playlist")

                for track in playlist_info["entries"]:
                    if track:
                        tracks.append(self._format_track_data(track))

                return tracks
        except Exception as e:
            raise ValueError(f"Error while extracting playlist: {str(e)}")

    @staticmethod
    def _format_track_data(data: Dict) -> Dict[str, Any]:
        return {
            "id": data.get("id"),
            "title": data.get("title"),
            "artist": data.get("channel") or data.get("uploader"),
            "duration": data.get("duration"),
            "thumbnail": data.get("thumbnail"),
            "source": "youtube",
            "url": data.get("webpage_url") or f"https://www.youtube.com/watch?v={data.get('id')}",
            "download_info": {
                "extractor": data.get("extractor"),
            }
        }