import re
from fastapi import FastAPI
from telethon import TelegramClient, sync
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

api_id = '29503745'
api_hash = 'e70a6041570a86992c77795b2dd60fca'
client = TelegramClient('airdrop_session', api_id, api_hash)

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 출처 허용 (개발 시)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    await client.start()

@app.on_event("shutdown")
async def shutdown_event():
    await client.disconnect()

class ChatRequest(BaseModel):
    chat_id: str
    limit: int = 100

def convert_text_to_html(text):
    # Replace newline with <br> for HTML formatting
    text = text.replace('\n', '<br>')

    # Hyperlink
    
    return text

@app.post("/scrape_messages")
async def scrape_messages(request: ChatRequest):
    messages = []
    async for message in client.iter_messages(request.chat_id, limit=request.limit):
        chat_username = (await client.get_entity(request.chat_id)).username
        message_url = f'https://t.me/{chat_username}/{message.id}'
        message_text = convert_text_to_html(message.message)
        messages.append({
            'date': message.date,
            'sender_id': message.sender_id,
            'text': message_text,
            'url': message_url
        })
    return messages
