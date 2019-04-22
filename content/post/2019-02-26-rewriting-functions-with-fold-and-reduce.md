+++
title = "Rewriting functions with fold and reduce"
date = 2019-04-22T00:00:00+01:00
publishDate= 2019-04-22T00:01:00+01:00
description = "How to use fold and reduce to rewrite any function that operates on lists"
draft = false
categories = ["tech"]
tags = ["javascript", "nodejs", "haskell", "programming", "tutorial"]
keywords = ["javascript", "nodejs", "haskell", "programming", "tutorial"]
toc = true
images = [
	"/img/fold.jpg"
]
+++

---

![Folding Paper](/img/fold.jpg "Folding Paper")

## Introduction

In this post, I will explain how it is possible to use `fold`(in Haskell) or `reduce`(in JavaScript) to rewrite some common array functions to get a basic understanding of how they work and how much you can do with it.

So, if you want to learn how `fold`/`reduce` work and what a powerful function it is, this post is for you.

## How does fold/reduce work?

`fold`/`reduce` iterates over a list and operates on the current element and the already processed ones. 

I must admit that this sounds a bit confusing, but I hope you will understand what that means while reading this article.

There is a slight difference in the Haskell `fold` and the JavaScript `reduce`, the Haskell one is curried by default but that shouldn't bother us.
Let us look at the function definition first:

{{<  highlight haskell >}}
foldl :: Foldable t => (b -> a -> b) -> b -> t a -> b
{{<  /highlight >}}

This look weird, an annotated version would look like this:

{{<  highlight haskell >}}
                       (                first param            ) -> ( second param  )   (third param)
                       (Accumulator -> CurrentElement -> Result)    (NeutralElement) -> (Foldable)    -> Result
foldl :: Foldable t => (    b       ->       a        ->   b   ) ->       b          ->    t a        -> b
{{<  /highlight >}}

`Foldable` is a so-called Type class and says that the type `t` must implement the `Foldable` interface, as long as it does nothing matters.

The first argument is a function which takes two arguments, the so-called accumulator which contains the already calculated result until this stage and the current element of the `Foldable` which is processed now.
This function returns a result which is the accumulator in the next run. 

The second argument is the neutral element which is the accumulator of the first iteration of this function. You can think of it as the default value or the starting value.

The third argument is the `Foldable` over which the function is iterating, this can be a List/Array for example.

So, `fold`/`reduce` needs a function which gets two arguments the current element of the iteration and the result of the already processed iterations, a neutral element and a list and returns something the same type as the neutral element.

`fold`/`reduce` iterates over a list(`Foldable`) and operates on the current element and the already processed ones. 
Does this sound more clear now? Don't worry if not, you will get it when looking at the examples.

Theoretically, you can do everything on a `Foldable` you want. You can calculate a single result out of it (like a `sum` function or a `length` function), calculate a new value for each element (like `map`) or transform the values into a completely new structure.
Still confused? Then go and read on how we implement some functions.

## Length

Length is a function that gets an array and returns the amount of the elements inside an array.
So it counts the array elements.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
length' :: [a] -> Int
length' = foldl (\acc _ -> acc + 1) 0

length' [1..5] -- 5
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const length = arr => arr.reduce(acc => acc + 1, 0)

length([1, 2, 3, 4, 5]); // 5
{{< /highlight >}}

We iterate over the array and add one for each element to the accumulator, which is zero as the default.
As we don't need the actual value of the current element we leave this argument blank.

## Sum/Max/Min

### Sum

Sum is a function that gets an array and returns the sum of the elements of that array.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
sum' :: [Int] -> Int
sum' = foldl (\acc curr -> acc + curr) 0

sum' [1..5] -- 15
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const sum = arr => arr.reduce((acc, curr) => acc + curr, 0);

sum([1, 2, 3, 4, 5]); // 15
{{< /highlight >}}

We iterate over the array and add the value of the current value to the accumulator, which is zero as the default.

### Max

Max is a function that gets an array and returns the maximum of that array.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
max' :: [Int] -> Int
max' (x:xs) = foldl (\acc curr -> if curr > acc then curr else acc) x xs

max' [1..5] -- 5
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const max = arr => arr.reduce((acc, curr) => (curr > acc ? curr : acc), arr[0]);

max([1, 2, 3, 4, 5]); // 5
{{< /highlight >}}

We iterate over the array and look if the current element is greater than the accumulator, if so we use the current element otherwise we use the accumulator and the neutral element is the first element of the array.
This returns the maximum of an array.

### Min

Min is a function that gets an array and returns the minimum of that array.  
The implementation is similar to the `max`-function but with the opposite comparison.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
min' :: [Int] -> Int
min' (x:xs) = foldl (\acc curr -> if curr < acc then curr else acc) x xs

min' [1..5] -- 1
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const min = arr => arr.reduce((acc, curr) => (curr < acc ? curr : acc), arr[0]);

min([1, 2, 3, 4, 5]); // 1
{{< /highlight >}}

## Elem(Includes)/Delete

### Elem(Includes)

Elem, in JavaScript it is called includes, is a function that gets an element and an array and returns whether the element is an element of that array or not.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
elem' :: Eq a => a -> [a] -> Bool
elem' item = foldl (\acc curr -> if item == curr then True else acc ) False

elem' 3 [1..5] -- True
elem' 8 [1..5] -- False

{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const includes = item => arr =>
  arr.reduce((acc, curr) => (item === curr ? true : acc), false);

includes(3)([1, 2, 3, 4, 5]); // true
includes(8)([1, 2, 3, 4, 5]); // false
{{< /highlight >}}

We iterate over the array and check if the current element is the same as the element we are searching for if it is we return true otherwise we return false and on the first run the accumulator is set to false.
So if the element is inside the array we set the accumulator to true and it has no possibility to be set to false again.

### Delete

Delete is a function that gets an element and an array and returns the array without every occurrence of that element.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
delete' :: Eq a => a -> [a] -> [a]
delete' item = foldl (\acc curr -> if item == curr then acc else acc ++ [curr] ) []

delete' 3 [1..5] -- [1,2,4,5]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
// delete is a keyword in JavaScript
const myDelete = item => arr =>
  arr.reduce((acc, curr) => (item === curr ? acc : acc.concat(curr)), []);

myDelete(3)([1, 2, 3, 4, 5]); // [ 1, 2, 4, 5 ]
{{< /highlight >}}

We iterate over the list and check if the current element is the same as the one we want to delete from the list, 
if so we return the accumulator otherwise we concatenate the accumulator with the current element and return the result.
The neutral element is an empty array.

## Head/Last/Tail/Reverse

### Head

Head is a function that gets an array and returns the first element of that array.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
head' :: [a] -> a
head' (x:xs) = foldl (\acc _ -> acc) x xs

head' [1..5] -- 1
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const head = arr => arr.reduce(acc => acc, arr[0]);

head([1, 2, 3, 4, 5]); // 1
{{< /highlight >}}

We set the neutral element to the first element of the array and in the processing function, we return only the accumulator, so the result can't be anything but the first element.

### Last

Last is a function that gets an array and returns the last element of that array.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
last' :: [a] -> a
last' (x:xs) = foldl (\_ curr -> curr) x xs

last' [1..5] -- 5
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const last = arr => arr.reduce((_, curr) => curr, arr[0]);

last([1, 2, 3, 4, 5]); // 5
{{< /highlight >}}

We set the neutral element to the first element of the array and in the processing function, we always return the current element, so the result is the last element eventually.

### Tail

Tail is a function that gets an array and returns all except the first element of that array.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
tail' :: [a] -> [a]
tail' (x:xs) = foldl (\acc curr -> acc ++ [curr]) [] xs

tail' [1..5] -- [2,3,4,5]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const tail = arr =>
  arr.reduce((acc, curr, index) => (index > 0 ? acc.concat(curr) : acc), []);

tail([1, 2, 3, 4, 5]); // [ 2, 3, 4, 5 ]
{{< /highlight >}}

This time the Haskell and the JavaScript implementation is slightly different.

In Haskell, we use everything but the first element as the processing list and concatenate every element onto the accumulator.

In JavaScript, we iterate over the whole list but use the `index` argument which is coming from reduce to check if the current element is the first element (index 0) or not and concatenate the elements onto the accumulator.

The neutral element is an empty array.

### Reverse

Reverse is a function that gets an array and returns the array in the opposite order.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
reverse' :: [a] -> [a]
reverse' = foldl (\acc curr -> curr : acc ) []

reverse' [1..5] -- [5,4,3,2,1]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const reverse = arr => arr.reduce((acc, curr) => [curr].concat(acc), []);

reverse([1, 2, 3, 4, 5]); // [ 5, 4, 3, 2, 1 ]
{{< /highlight >}}

We iterate over the array and concatenate the accumulator onto the current element on each iteration.

The neutral element is an empty array.

## All/Any

### All

All is a function that gets a function (from the element of that list to bool) and an array and returns whether every element in that array matches the condition.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
all' :: (a -> Bool) -> [a] -> Bool
all' f = foldl (\acc curr -> f curr && acc) True

all' (>2) [1..5] -- False
all' (>0) [1..5] -- True

{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const all = fn => arr => arr.reduce((acc, curr) => fn(curr) && acc, true);

all(i => i > 2)([1, 2, 3, 4, 5]); // false
all(i => i > 0)([1, 2, 3, 4, 5]); // true
{{< /highlight >}}

We get a function as an argument and we set the neutral element to `True`.

We process every element with the function and do a logical `and` with the accumulator.

### Any

Any is a function that gets a function (from the element of that list to bool) and an array and returns whether any element in that array matches the condition.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
any' :: (a -> Bool) -> [a] -> Bool
any' f = foldl (\acc curr -> f curr || acc) False

any' (>2) [1..5] -- True
any' (>10) [1..5] -- False
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const any = fn => arr => arr.reduce((acc, curr) => fn(curr) || acc, false);

any(i => i > 2)([1, 2, 3, 4, 5]); // true
any(i => i > 10)([1, 2, 3, 4, 5]); // false
{{< /highlight >}}

Similar to `all` but we set the neutral element to false and do a logical `or` with the accumulator and the processed element.

## Take

Take is a function that gets a positive integer and an array and returns an array with the first elements until the list is as big as the passed integer.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
take' :: Int -> [a] -> [a]
take' n = foldl (\acc curr -> if length acc == n then acc else acc ++ [curr]) []

take' 2 [1..5] -- [1,2]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const take = n => arr =>
  arr.reduce((acc, curr) => (acc.length === n ? acc : acc.concat(curr)), []);

take(2)([1, 2, 3, 4, 5]); // [ 1, 2 ]
{{< /highlight >}}

The neutral element is an empty list and we check if the accumulator is of the length of the number of elements we want to receive, if so we just return the accumulator otherwise 
we concatenate the accumulator with the current element and return that result.

## Map

Map is a function that gets a function and an array and returns an array of the same size where every element was applied to that function.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
map' :: (a -> b) -> [a] -> [b]
map' f = foldl (\acc curr -> acc ++ [f curr]) []

map' (*2) [1..5] -- [2,4,6,8,10]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const map = fn => arr => arr.reduce((acc, curr) => acc.concat(fn(curr)), []);

map(i => i * 2)([1, 2, 3, 4, 5]); // [ 2, 4, 6, 8, 10 ]
{{< /highlight >}}

We concatenate the accumulator with the result of the function we get as an argument and the current element and return that inside our processing function.

## Filter

Filter is a function that gets a function (from the element of that list to bool) and an array and returns a new array with the elements of the first list matching these condition.

<sub>Haskell implementation:</sub>
{{<  highlight haskell >}}
filter' :: (a -> Bool) -> [a] -> [a]
filter' f xs = foldl (\acc curr -> if f curr then acc ++ [curr] else acc ) [] xs

filter' (<4) [1..5] -- [1,2,3]
{{< /highlight >}}

<sub>JavaScript implementation:</sub>
{{<  highlight javascript >}}
const filter = fn => arr =>
  arr.reduce((acc, curr) => (fn(curr) ? acc.concat(curr) : acc), []);

filter(i => i < 4)([1, 2, 3, 4, 5]); // [ 1, 2, 3 ]
{{< /highlight >}}

In our processing function, we check if the current element applied to the passed function is `True`, if so we concatenate the accumulator with the current element otherwise we only return the accumulator.

## Closing

I hope you can see that `fold`/`reduce` is a very powerful tool and that you can do anything on arrays with it.
If we would reread the sentence from before I think it feels much clearer now: 

> `fold`/`reduce` iterates over a list(`Foldable`) and operates on the current element and the already processed ones.

If you want to read more about it I would recommend these three links:

* [Wikipedia](https://en.wikipedia.org/wiki/Fold_(higher-order_function))
* [Haskell Wiki](https://wiki.haskell.org/Fold)
* [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce)
