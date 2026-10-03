from typing import List

from pydantic import BaseModel


class TrackSchema(BaseModel):
    title: str | None
    artist: str | None
    duration: int | None
    thumbnail_url: str | None
    source_url: str | None

class PlaylistSchema(BaseModel):
    name: str | None = None
    description: str | None = None
    cover_url: str | None = None
    tracks: List[TrackSchema]