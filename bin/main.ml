open Lwt.Infix

(* Mutable list to keep track of connected clients *)
let clients = ref []

(* Broadcast a message to all connected clients except the sender *)
let broadcast sender message =
  Lwt_list.iter_p
    (fun (_, client_out, _) ->
      if client_out != sender then
        try%lwt Lwt_io.write_line client_out message with _ -> Lwt.return_unit
      else Lwt.return_unit)
    !clients

(* Handle a single connected client *)
let client_handler client_addr (client_in, client_out) =
  let address_string =
    match client_addr with
    | Unix.ADDR_UNIX s -> s
    | ADDR_INET (ip, port) ->
        Printf.sprintf "%s:%d" (Unix.string_of_inet_addr ip) port
  in
  let%lwt () = Lwt_io.printf "Client connected: %s\n" address_string in
  try%lwt
    (* Read the username from the client *)
    let%lwt username = Lwt_io.read_line client_in in
    (* Add the client to the list *)
    clients := (client_in, client_out, username) :: !clients;
    let%lwt () = broadcast client_out (username ^ " has joined the chat.") in
    (* Continuously read messages from the client *)
    let rec read_loop () =
      let%lwt message = Lwt_io.read_line client_in in
      let full_message = username ^ ": " ^ message in
      let%lwt () =
        Lwt_io.printf "Message received from %s: %s\n" address_string message
      in
      broadcast client_out full_message >>= read_loop
    in
    read_loop ()
  with End_of_file -> (
    (* Handle client disconnection *)
    let user_disconnected =
      List.find_opt (fun (_, c_out, user) -> c_out == client_out) !clients
    in
    match user_disconnected with
    | Some (_, _, username) ->
        clients :=
          List.filter (fun (_, c_out, _) -> c_out != client_out) !clients;
        let%lwt () = Lwt_io.printf "Client disconnected: %s\n" address_string in
        broadcast client_out (username ^ " has left the chat.")
    | None -> Lwt.return_unit)

(* Run the server *)
let run_server ip port =
  let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string ip, port) in
  let server () =
    let%lwt () = Lwt_io.printf "Server running on %s:%d\n" ip port in
    let%lwt _server =
      Lwt_io.establish_server_with_client_address sockaddr client_handler
    in
    let%lwt () = Lwt_io.printf "Press Ctrl+C to stop the server\n" in
    let never_resolved, _ = Lwt.wait () in
    never_resolved
  in
  Lwt_main.run (server ())

(* Run the client *)
let run_client ip port username =
  let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string ip, port) in
  let client () =
    let%lwt server_in, server_out = Lwt_io.open_connection sockaddr in
    let%lwt () = Lwt_io.write_line server_out username in
    let%lwt () = Lwt_io.printf "Connected to the server as %s\n" username in
    (* Read and write loop *)
    let rec chat () =
      Lwt.choose
        [
          (Lwt_io.read_line_opt server_in >|= function
           | Some message -> Printf.printf "\r%s\n%!" message
           | None -> ());
          ( Lwt_io.read_line Lwt_io.stdin >>= fun message ->
            Lwt_io.write_line server_out message );
        ]
      >>= chat
    in
    chat ()
  in
  Lwt_main.run (client ())

(* Main entry point *)
let () =
  let print_usage () =
    Printf.printf "Usage: %s <server | client> <IP> <PORT> [USERNAME]\n"
      Sys.argv.(0)
  in
  if Array.length Sys.argv < 4 then print_usage ()
  else
    match Sys.argv.(1) with
    | "server" ->
        let ip = Sys.argv.(2) in
        let port = int_of_string Sys.argv.(3) in
        run_server ip port
    | "client" ->
        if Array.length Sys.argv < 5 then print_usage ()
        else
          let ip = Sys.argv.(2) in
          let port = int_of_string Sys.argv.(3) in
          let username = Sys.argv.(4) in
          run_client ip port username
    | _ -> print_usage ()
