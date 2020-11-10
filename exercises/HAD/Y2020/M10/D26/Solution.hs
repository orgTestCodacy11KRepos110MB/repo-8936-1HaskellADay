{-# LANGUAGE OverloadedStrings #-}

module Y2020.M10.D26.Solution where

{--
Great! We have the airbases of the world. At some point we will want to 
look at alliances of the world:

https://en.wikipedia.org/wiki/List_of_military_alliances

But FRIST! ... let's export our graph as a set of cypher statements
--}

import Data.Map (Map)
import qualified Data.Map as Map
import Data.Set (Set)

import qualified Data.Text as T

import Graph.Query
import Graph.JSON.Cypher

import Y2020.M10.D12.Solution   -- to load the airbases
import Y2020.M10.D14.Solution   -- to load countries-continents
import Y2020.M10.D15.Solution   -- for the country map
import Y2020.M10.D16.Solution   -- cyphed countries-continents
import Y2020.M10.D20.Solution   -- for cyphed stuff
import Y2020.M10.D23.Solution   -- for ununicoded base names

-- an a loader, free of charge:

loadAll :: IO (Map Icao AirBase, CountryMap, Set Country, Set Country)
loadAll =
   loadBases (Y2020.M10.D12.Solution.workingDir ++ file) >>= \bs ->
   countriesByContinent (Y2020.M10.D14.Solution.workingDir ++ cbc) >>= \conti ->
   let cm = countryMap conti
       mbs = byICAO bs
       newabm = firstPass mbs
       ccs = countries fst cm
       abc = countries (country . snd) newabm
       nonu = stripNonAscii newabm in
   return (nonu, cm, ccs, abc)

-- With the above, you should be able to implement the following

countriesCypher :: CountryMap -> [Cypher]
countriesCypher = map (mkCypher "a" "rel" "b") . relationalize

countriesCorrections :: Set Country -> Set Country -> [Cypher]
countriesCorrections = secondPass

airbaseCypher :: Map Icao AirBase -> [Cypher]
airbaseCypher = map (mkCypher "a" "rel" "b" . loadIt) . Map.toList

saveCypher :: FilePath -> [Cypher] -> IO ()
saveCypher file = writeFile file . T.unpack . T.unlines

go :: IO ()
go = loadAll >>= \(abm, cm, ccs, abc) ->
     saveCypher "01-raw-countries.cyp" (countriesCypher cm) >>
     putStrLn "Saved countries" >>
     saveCypher "02-countries-corrections.cyp" (countriesCorrections ccs abc) >>
     putStrLn "Saved corrections" >>
     saveCypher "03-airbases.cyp" (airbaseCypher abm) >>
     putStrLn "Yeah. We're done."