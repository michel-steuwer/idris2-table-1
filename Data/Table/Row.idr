module Data.Table.Row

import Data.List
import public Data.SnocList

import public Data.Table.Data
import public Data.Table.Row.Aggregate
import public Data.Table.Row.Constructor
import public Data.Table.Row.Frame
import public Data.Table.Row.HasRows

%default total

public export
toSnocList : Table schema -> SnocList (Record schema)
toSnocList [<] = [<]
toSnocList (tbl :< rec) = toSnocList tbl :< rec

public export
elemBy : (Record schema -> Record schema -> Bool) -> Record schema -> Table schema -> Bool
elemBy f rec tbl = elemBy f rec (toSnocList tbl)

public export
elem : Eq (Record schema) => Record schema -> Table schema -> Bool
elem = elemBy (==)

public export
map : (Record schema -> a) -> Table schema -> SnocList a
map f [<] = [<]
map f (tbl :< rec) = map f tbl :< f rec

export
mapPreservesLength : HasRows tbl n => HasRows tbl (length (map f tbl))
mapPreservesLength @{EmptyTable} = EmptyTable
mapPreservesLength @{SnocTable _} = SnocTable mapPreservesLength

public export
foldr : (Record schema -> a -> a) -> a -> Table schema -> a
foldr f x [<] = x
foldr f x (tbl :< rec) = foldr f (f rec x) tbl

public export
distinctBy : (Record schema -> Record schema -> Bool) -> Table schema -> Table schema
distinctBy f tbl = foldl (\acc, rec => ifThenElse (elemBy f rec acc) acc (acc :< rec)) [<] $ toSnocList tbl

public export
distinct : Eq (Record schema) => Table schema -> Table schema
distinct = distinctBy (==)

export
sortBy : (Record schema -> Record schema -> Ordering) -> Table schema -> Table schema
sortBy cmp tbl = mkTable $ List.sortBy cmp (cast $ toSnocList tbl)

export
sort : Ord (Record schema) => Table schema -> Table schema
sort = sortBy compare

public export
filter : (Record schema -> Bool) -> Table schema -> Table schema
filter f [<] = [<]
filter f (rows :< rec) =
    let rest = filter f rows in
    case f rec of
        False => rest
        True => rest :< rec
