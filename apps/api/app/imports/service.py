from app.core.exceptions import ResourceNotFoundException
from app.imports.schemas import PlaylistSchema, TrackSchema
from app.providers.factory import ProviderFactory


class ImportService:
    def __int__(self):
        pass

    @staticmethod
    def import_playlist(url: str) -> PlaylistSchema:
        try:
            provider = ProviderFactory.get_provider(url)
        except ValueError as e:
            raise ResourceNotFoundException(str(e))

        if not provider.validate_url(url):
            raise ResourceNotFoundException(f"Playlist url {url} not supported")

        tracks_data = provider.extract_playlist(url)

        return PlaylistSchema(tracks=tracks_data)

    @staticmethod
    def import_track(url: str) -> TrackSchema:
        if not ProviderFactory.get_provider(url).validate_url(url):
            raise ResourceNotFoundException("Track url {} not supported".format(url))

        return ProviderFactory.get_provider(url).extract_track(url)