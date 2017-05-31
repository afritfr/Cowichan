use "collections"
use "random"
use "../../gsl"

// first to define a matrix class we need to define its primitives
struct GslVector
    var size: USize = 0
    var stride: USize = 0
    var data: F64 = 0
    var block: GslBlock = (0,Pointer[F64])
    var owner: I32 = 0
    new create() => None

type PtrGslVector is MaybePointer[GslVector]

class Vector

    let _pv: PtrGslVector
    var s : USize // number of elements
    let mt : MT= MT() // used to generate random elements

    new create(s': USize, init: Bool = false) =>
        s=s'
        if init then
            _pv = @gsl_vector_calloc [PtrGslVector](s)
        else
            _pv = @gsl_vector_alloc [PtrGslVector](s)
        end



    fun _final() => @gsl_vector_free[None](_pv)
    fun setAll(x: F64) => @gsl_vector_all[None](_pv,x)
    fun setZero() => @gsl_vector_set_zero[None](_pv)
    fun setBasis(i:USize): I64 => @gsl_vector_set_basis[I64](_pv,i)
    fun get(i: USize) : F64 =>@gsl_vector_get[F64](_pv, i)
    fun set(i: USize, x: F64) => @gsl_vector_set[None](_pv, i, x)
    fun _in_bounds(i: USize) : Bool => i<s

    fun ref update(i: USize, value: F64) : F64 =>
      // the receiver must be ref
      let old = this.get(i)
      if _in_bounds(i) then this.set(i,value) else @printf[None](("Vector Write Error: Out of bounds\n").cstring()) end
      old

    fun apply(i: USize) : (F64|None) =>
      if _in_bounds(i) then this.get(i) else @printf[None](("Vector Read Error: Out of bounds\n").cstring()) end
    fun ref randomize () : Vector=>
      // just fill the vector with random elements

        for i in Range(0, s) do
           this(i) = mt.next().f64() / U64.max_value().f64()
        end
        this


  fun display() =>
      @printf[I32](("[ ").cstring())
        for i in Range(0,s) do
          @printf[I32]((this.get(i).string()+" ").cstring())
        end
        @printf[I32](("] \n").cstring())
/*
  new _from_pointer (pv : PtrGslVector)  =>
    _pv = pv
    // TODO : update the size
    // s = _pv().size
    s =0

  fun view(from : USize, to: USize)  =>
    //Function: gsl_vector_view gsl_vector_subvector (gsl_vector * v, size_t offset, size_t n)
     @gsl_vector_subvector[PtrGslVector](_pv,from,to)
    //returning another pointer to vector wrapped around the class
    //Vector._from_pointer(pointer)
*/
  fun printf(str: String) =>
    @printf[None](str.cstring())

// how to read from the struct
  fun size_from_struct() =>
    try this.printf(_pv.size.string()) else this.printf("could't get size") end
actor Main
    new create (env:Env) =>
    var v : Vector = Vector(5)
    v.randomize()
    v.display()
    //v.view(1,3)
  //  view.display()
  v.size_from_struct()