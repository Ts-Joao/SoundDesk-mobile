from abc import ABC, abstractmethod
from typing import Dict, Any


class ImportProvider(ABC):

    @abstractmethod
    def validate_url(self, url: str) -> bool:
        pass

    @abstractmethod
    def extract_playlist(self, url: str) -> Dict[str, Any]:
        pass

    @abstractmethod
    def extract_track(self, url: str) -> Dict[str, Any]:
        pass