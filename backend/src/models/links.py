from pydantic import BaseModel, HttpUrl

class Link(BaseModel):
    rel: str
    href: HttpUrl