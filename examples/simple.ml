open Printf
module BA=Bigarray

let () =
    let x = BA.Array2.of_array BA.float32 BA.c_layout
    [|
        [|0.; 1.; 0.|];
        [|1.; 0.; 0.|];
        |] in
    let y = BA.Array1.of_array BA.int32 BA.c_layout
        [|0l; 1l|] in
    let m = Ocpm.create () in
    Ocpm.fit ~iters:100 m x y;
    printf "now predict\n%!";
    let scores, assignments = Ocpm.predict m x in
    printf "0: %.2f\n" (BA.Array1.get scores 0);
    printf "1: %.2f\n" (BA.Array1.get scores 1);
    Ocpm.serialize_model m "cpm.model"

