from typing import Any, Dict, List

import requests
import spotipy
import yt_dlp
from spotipy import SpotifyClientCredentials

from app.core.config import settings
from app.providers.base import ImportProvider


class SpotifyProvider(ImportProvider):
    def __init__(self):
        client_id = settings.SPOTIPY_CLIENT_ID
        client_secret = settings.SPOTIPY_CLIENT_SECRET

        self.spotify = spotipy.Spotify(
            auth_manager=SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
        )

        self.ydl_opts = {
            'quiet': True,
            'extract_flat': True,
        }

    def validate_url(self, url: str) -> bool:
        return "spotify.com" in url or "spotify.link" in url

    @staticmethod
    def _resolve_short_link(url: str) -> str:
        if "spotify.link" in url:
            response = requests.head(url, allow_redirects=True)
            return response.headers.get('Location', url)
        return url

    def _search_youtube(self, query: str) -> str:
        with yt_dlp.YoutubeDL(self.ydl_opts) as ydl:
            result = ydl.extract_info(f"ytsearch1:{query}", download=False)
            if 'entries' in result and len(result['entries']) > 0:
                video_id = result['entries'][0]['id']
                return f"https://www.youtube.com/watch?v={video_id}"
        return ""

    def extract_track(self, url: str) -> Dict[str, Any]:
        """Extrai os dados do Spotify e já acha o link correspondente no YouTube"""
        url = self._resolve_short_link(url)

        try:
            track = self.spotify.track(url)
            title = track['name']
            artist = track['artists'][0]['name']

            search_query = f"{artist} - {title} audio"
            youtube_url = self._search_youtube(search_query)

            return {
                "id": track['id'],
                "title": title,
                "artist": artist,
                "duration": track['duration_ms'] / 1000,
                "thumbnail": track['album']['images'][0]['url'] if track['album']['images'] else None,
                "source": "spotify",
                "original_url": url,
                "youtube_url": youtube_url
            }
        except Exception as e:
            raise ValueError(f"Erro ao extrair faixa do Spotify: {str(e)}")

    def extract_playlist(self, url: str) -> List[Dict[str, Any]]:
        """Extrai todas as faixas e lida com a paginação do Spotify"""
        url = self._resolve_short_link(url)
        tracks = []

        try:
            playlist_id = url.split('/')[-1].split('?')[0]
            results = self.spotify.playlist_tracks(playlist_id)

            while results:
                for item in results['items']:
                    track = item.get('track')
                    if not track: continue

                    title = track['name']
                    artist = track['artists'][0]['name']

                    search_query = f"{artist} - {title} audio"

                    tracks.append({
                        "id": track['id'],
                        "title": title,
                        "artist": artist,
                        "duration": track['duration_ms'] / 1000,
                        "thumbnail": track['album']['images'][0]['url'] if track['album']['images'] else None,
                        "source": "spotify",
                        "youtube_query": search_query
                    })

                if results['next']:
                    results = self.spotify.next(results)
                else:
                    break

            return tracks
        except Exception as e:
            raise ValueError(f"Erro ao extrair playlist do Spotify: {str(e)}")