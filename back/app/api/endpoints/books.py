# app/api/endpoints/books.py - 書籍情報APIのエンドポイント

from fastapi import APIRouter, HTTPException
from typing import Optional
from app.services import book_service

router = APIRouter()

@router.get("/{isbn}", response_model=Optional[book_service.BookInfo])
async def get_book(isbn: str):
    book = await book_service.get_book_info(isbn)
    if book:
        return book
    else:
        raise HTTPException(status_code=404, detail="Book not found")