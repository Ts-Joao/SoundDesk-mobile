from typing import List

from pydantic import BaseModel


class TrackSchema(BaseModel):
    title: str
    artist: str
    duration: int
    thumbnail_url: str
    source_url: str

class PlaylistSchema(BaseModel):
    name: str
    description: str
    cover_url: str
    tracks: List[TrackSchema]