enum _VType {
  None = "None",
  Some = "Some",
}

export class Option<T> {
  #is_none: boolean = true;
  #val: T;

  static None = _VType.None
  static Some = _VType.Some
  
  private is_noney(a: unknown) {
    return [undefined, null].some((x) => x === a);
  }

  constructor(val: unknown) {
    this.#is_none = this.is_noney(val as T);
    this.#val = val as T;
  }

  get(): T {
    if (this.#is_none) {
      throw new Error("Trying to get a None value");
    }

    return this.#val
  }

  type(): _VType {
    if (this.#is_none) 
      return _VType.None

    return _VType.Some
  }

  map<K>(f: (v: T) => K): Option<K> {
    if (this.#is_none)
      return new Option(undefined)

    return new Option(f(this.get()))
  }

  with(f: (v: T) => unknown): Option<T> {
    if (!this.#is_none) f(this.get())
    return this
  }

  set<K>(val: K): Option<K> {
    return new Option(val)
  }
}
