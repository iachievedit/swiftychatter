import Glibc

let client = ChatterClient()

client.start()

select(0, nil, nil, nil, nil)
