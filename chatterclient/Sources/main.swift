import Glibc

let client = ChatterClient()

client.start()

while true {
  select(0, nil, nil, nil, nil)
}
