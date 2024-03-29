module Y2021.M04.D12.Exercise where

import Control.Monad.Fail (MonadFail)

{--
You want to create a "safe"-function, that is to say, depending on the
input, you get (or you don't get) an output.

What am I saying?

Take an ordinary function, let's say, a function that returns the
successors of the members of a list:
--}

successors :: Enum a => [a] -> [a]
successors = map succ

{--
Now, the twist.

You want successors to return a list, as above, if the list has at least
five members, if it has four members or less, you want the successors function
to fail with (e.g.:) Nothing, that is to say
--}

-- Added MonadFail to type-constraints, thanks to @clementd

successorsM :: Enum a => Monad m => MonadFail m => [a] -> m [a]
successorsM list = undefined

{--
And the return to be something like, e.g., for the Maybe monad:

>>> (successorsM [1,2,3]) :: Maybe [Int]
Nothing

>>> (successorsM [1,2,3,4,5]) :: Maybe [Int]
Just [2,3,4,5,6]

Or for the List monad:

>>> (successorsM [1,2,3,4,5]) :: [[Int]]
[[2,3,4,5,6]]

>>> (successorsM [1,2,3]) :: [[Int]]
[]
--}
