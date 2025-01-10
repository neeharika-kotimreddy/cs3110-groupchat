# Group Chat Application using Lwt in OCaml

This project implements a group chat application using the Lwt concurrency library in OCaml. The application enables multiple clients to connect to a single server over a network. Clients can send messages to the server, which then broadcasts those messages to all connected clients, creating a real-time group chat experience. The project progresses in two tasks: first building a digital bulletin board, and then extending it into a full-fledged group chat application. This is a project for the class CS 3110: Functional Programming and Data Structures in OCaml at Cornell, which I took in the fall 2024 semester.

## Description

The Group Chat Application is developed in two stages:

1. **Digital Bulletin Board**  
   - Clients connect to the server and send a single message.  
   - The server displays the messages on its terminal, acting like a digital bulletin board.  

2. **Group Chat App**  
   - Clients remain connected to the server and can send multiple messages.  
   - The server broadcasts each message to all connected clients, allowing real-time group communication.  
   - The server also handles client disconnections gracefully without crashing.

The app supports both server and client modes, requires minimal user interaction for the server, and leverages non-blocking I/O to handle multiple connections efficiently.

---

## Getting Started

### Dependencies

To run the Group Chat App, you will need:
- **OCaml 4.x** or higher
- **Lwt library** for asynchronous programming
- **Dune** for building and managing the project
- A computer with:
  - A network connection (for testing on different IPs)

### Installing

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/group-chat-lwt.git
2. Navigate to the project directory:
   ```bash
   cd group-chat-lwt
3. Build the project using Dune:
   ```bash
   dune build

### Executing Program

1. Run the server on a specified IP and port:
   ```bash
   dune exec bin/main.exe server <IP_ADDRESS> <PORT>
   dune exec bin/main.exe server 127.0.0.1 5001 --> example

2. Connect a client to the server by specifying the server's IP, port, and a username:
   ```bash
   dune exec bin/main.exe client <IP_ADDRESS> <PORT> <USERNAME>
   dune exec bin/main.exe client 127.0.0.1 5001 buffy --> example

3. The client can send multiple messages and stay connected until termination (Ctrl+C).

--- 

## Authors
* Neeharika Kotimreddy 
