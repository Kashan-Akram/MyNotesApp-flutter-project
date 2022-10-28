// function to filter from all notes based on the current user

extension Filter<T> on Stream<List<T>>{
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
