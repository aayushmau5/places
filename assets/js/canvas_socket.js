// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix";
import p5 from "p5";

// And connect to the path in "lib/places_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/places_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/places_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/places_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect();

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let channel = socket.channel("room:canvas", {});
channel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined successfully", resp);
    initCanvas(resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join", resp);
  });

// Canvas
const initCanvas = ({ rows, cols, cellSize }) => {
  const canvas = document.getElementById("canvas");

  const grid = new Array(rows).fill(0).map(() => new Array(cols).fill(0));
  console.log(grid);
  channel.on("click", ({ x, y }) => {
    grid[y][x] = 1.0;
  });

  const setup = (p5) => {
    p5.createCanvas(cellSize * cols, cellSize * rows + cellSize, canvas);
    p5.background(255);
    p5.noStroke();
  };

  const draw = (p5) => {
    // vars
    const [x, y] = [
      p5.floor(p5.mouseX / cellSize),
      p5.floor(p5.mouseY / cellSize),
    ];

    // main
    for (let i = 0; i < rows; i++) {
      for (let j = 0; j < cols; j++) {
        grid[i][j] = p5.max(0, grid[i][j] - p5.deltaTime / 1000.0 / 10.0);
        p5.fill(255, 255 * (1 - grid[i][j]), 255);
        p5.rect(j * cellSize, i * cellSize, cellSize, cellSize);
      }
    }

    // mouse
    p5.fill(160);
    p5.rect(x * cellSize, y * cellSize, cellSize, cellSize);

    // status bar
    p5.fill(240, 240, 240);
    p5.rect(0, p5.height - cellSize, p5.width, cellSize);
    p5.fill(0);
    p5.text(`(${x}, ${y})`, 10, p5.height - 5);
  };

  const mouseClicked = (p5) => {
    const [x, y] = [
      p5.floor(p5.mouseX / cellSize),
      p5.floor(p5.mouseY / cellSize),
    ];

    channel.push("click", { x, y });
  };

  const sketch = (p) => {
    p.setup = () => setup(p);
    p.draw = () => draw(p);
    p.mouseClicked = () => mouseClicked(p);
  };

  new p5(sketch);
};
