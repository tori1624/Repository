async function fetchMessages(chatId, limit) {
    
    // 서버에 POST 요청을 보내 텔레그램 메시지를 가져옵니다.
    const response = await fetch('http://localhost:8000/scrape_messages', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ chat_id: chatId, limit: parseInt(limit) })
    });
    
    // 서버로부터 JSON 형식의 메시지 데이터를 받습니다.
    const messages = await response.json();

    // messages라는 ID를 가진 HTML 요소를 가져와 비웁니다.
    const messagesDiv = document.getElementById('messages');

    // 각 채팅 ID에 대한 컨테이너를 생성합니다.
    const chatContainer = document.createElement('div');
    chatContainer.className = 'chat-container';
    chatContainer.innerHTML = `<h4>Messages for ${chatId}</h4>`;

    // 각 메시지를 HTML 요소로 만들어 messagesDiv에 추가합니다.
    messages.forEach(message => {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message';
        messageDiv.innerHTML = `
            <p><strong>${new Date(message.date).toLocaleString()}</strong> - ${message.sender_id}</p>
            <p>${message.text}</p>
            <p><a href="${message.url}" target="_blank">View Message</a></p>
        `;
        chatContainer.appendChild(messageDiv);
    });

    messagesDiv.appendChild(chatContainer);
}

// 페이지가 로드될 때 fetchMessages() 함수를 자동으로 호출합니다.
document.addEventListener('DOMContentLoaded', (event) => {
    const chatIds = ["@WeCryptoTogether", "@mujammin123", "@marshallog"];
    const limit = 1;

    chatIds.forEach(chatId => {
        fetchMessages(chatId, limit);
    });
});
