from urllib.parse import urlparse

from app.providers.spotify import SpotifyProvider
from app.providers.youtube import YoutubeProvider


class ProviderFactory:

    @staticmethod
    def get_provider(url: str):
        parsed_url = urlparse(url)
        domain = parsed_url.netloc.lower()

        if "youtube.com" in domain or "youtu.be" in domain:
            return YoutubeProvider()
        elif "spotify.com" in domain or "spotify.link" in domain:
            return SpotifyProvider()
        else:
            raise ValueError(f"Unknown provider: {url}")