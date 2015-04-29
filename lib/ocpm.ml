open Printf
open Ctypes
open Foreign
module BA=Bigarray

let dataset = ptr void
let model = ptr void
let from = Dl.(dlopen ~filename:"libcpm.so" ~flags:[RTLD_NOW])

let create = foreign ~from "create" (void @-> returning model)

let _fit = foreign ~from "fit" (model @-> ptr float @-> ptr int32_t @-> size_t @->
    size_t @-> int @-> bool @-> bool @-> returning void)
let _predict = foreign ~from "predict" (model @-> ptr float @-> ptr int32_t @-> size_t @->
    size_t @-> ptr float @-> ptr int32_t @-> returning void)
let _predict_dataset = foreign ~from "predict_dataset" (model @-> dataset @-> ptr float @-> ptr int32_t @-> returning void)

let serialize_model = foreign ~from "serializeModel" (model @-> string @-> returning void)

let _dataset_from_file = foreign ~from "cpm_dataset_from_file" (string @-> size_t @-> returning dataset)
let dataset_from_file fn ?(n_instances=1000000) =
    _dataset_from_file fn (Unsigned.Size_t.of_int n_instances)

let get_k = foreign ~from "get_k" (model @-> returning int)
let _get_n_instances = foreign ~from "cpm_dataset_get_n_instances" (dataset @-> returning size_t)
let get_n_instances ds = Unsigned.Size_t.to_int (_get_n_instances ds)

let fit ?(iters=10) m x y =
    _fit 
        m 
        (bigarray_start array2 x) 
        (bigarray_start array1 y) 
        (BA.Array2.dim1 x |> Unsigned.Size_t.of_int)
        (BA.Array2.dim2 x |> Unsigned.Size_t.of_int)
        iters true true

let predict m x =
    let num_rows = BA.Array2.dim1 x in
    let scores = BA.Array1.create BA.float32 BA.c_layout num_rows in
    let assignments = BA.Array1.create BA.int32 BA.c_layout num_rows in
    let y = BA.Array1.create BA.int32 BA.c_layout num_rows in
    _predict
        m 
        (bigarray_start array2 x) 
        (bigarray_start array1 y)
        (Unsigned.Size_t.of_int num_rows)
        (BA.Array2.dim2 x |> Unsigned.Size_t.of_int)
        (bigarray_start array1 scores) (bigarray_start array1 assignments);
    scores, assignments

let predict_dataset m ds =
    let num_rows = get_n_instances ds in
    let scores = BA.Array1.create BA.float32 BA.c_layout num_rows in
    let assignments = BA.Array1.create BA.int32 BA.c_layout num_rows in
    _predict_dataset m  ds
        (bigarray_start array1 scores) (bigarray_start array1 assignments);
    scores, assignments

let dude () =
    let x = BA.Array2.of_array BA.float32 BA.c_layout
    [|
        [|0.; 1.; 0.|];
        [|1.; 0.; 0.|];
        |] in
    let y = BA.Array1.of_array BA.int32 BA.c_layout
        [|0l; 1l|] in
    let m = create () in
    fit ~iters:100 m x y;
    printf "now predict\n%!";
    let scores, assignments = predict m x in
    printf "0: %.2f\n" (BA.Array1.get scores 0);
    printf "1: %.2f\n" (BA.Array1.get scores 1);
    serialize_model m "cpm.model";
    scores, assignments

