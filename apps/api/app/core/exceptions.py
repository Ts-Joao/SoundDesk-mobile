
class CustomException(Exception):
    def __init__(self, message: str, status_code: int = 400, code: str = "BAD_REQUEST"):
        self.message = message,
        self.status_code = status_code,
        self.code = code

class ResourceNotFoundException(CustomException):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message=message, status_code=404, code="NOT_FOUND")