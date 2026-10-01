from fastapi import APIRouter
from starlette import status

from app.imports.schemas import PlaylistSchema, TrackSchema
from app.imports.service import ImportService


router = APIRouter(prefix="/imports", tags=["imports"])

@router.post(
    "/playlist",
    status_code=status.HTTP_201_CREATED,
    response_model=PlaylistSchema,
)
def import_playlist(url: str) -> PlaylistSchema:
    return ImportService.import_playlist(url)

@router.post(
    "/track",
    status_code=status.HTTP_201_CREATED,
)
def import_track(url: str) -> TrackSchema:
    return ImportService.import_track(url)