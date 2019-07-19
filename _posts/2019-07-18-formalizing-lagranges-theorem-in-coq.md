---
layout: post
title: "Formalizing Lagrange's Theorem in Coq"
comments: true
---

I recently finished [writing up a proof](https://github.com/tildedave/coq-playground/blob/master/groups.v) of Lagrange's Theorem in [Coq](https://coq.inria.fr/), an interactive theorem prover.

<div class="theorem" text="Lagrange's Theorem">
Let $G$ be a finite group and $H$ a subgroup of $G$.  Then the order of $H$ divides the order of $G$.
</div>

Lagrange's Theorem is probably the first nontrivial result that gets proved in a group theory course.  Group theory is the study of permutations and how they behave under composition.  The theorem states states that if you have a group with (for example) 10 elements, its the size of its subgroups (smaller groups contained in the larger group) must divide 10.  So you can have subgroups of size 1, 2, 5, and 10 (the whole group), and that's it.

While Lagrange's Theorem doesn't guarantee the existence of such a group (though this is true by Sylow's Theorem for prime powers that divide the group order), it's still quite useful for understanding group structures.  One result that follows from Lagrange's Theorem is that finite groups of prime order have no non-trivial subgroups.

## Coq

I first encountered Coq in graduate school.  I had done some coursework with [Twelf](http://twelf.org/wiki/Main_Page) which was primarily aimed at programming language semantics verification, whereas Coq was a more general tool that could prove properties about the natural numbers or the integers.  The Coq type system is basically Haskell on steroids - you write a program, it's expressive enough to be able to prove its correctness.

In practice this ends up being a blend of fun and frustrating.  In order for the Coq type-checker to work, its programs must be proved to terminate, which means that recursive functions must use structural recursion.  For example,

```coq
Import PeanoNat.

Fixpoint wont_type_check n :=
  match n with
  | 0 => 0
  | S m => wont_type_check (m / 2)
  end.
```

This program takes any natural number and performs an integer division by 2, then returns 0 when it gets to 0.  "Obviously", this function will always return, but the Coq type checker fails to type check it:

```coq
Error:
Recursive definition of wont_type_check is ill-formed.
...
Recursive call to wont_type_check has principal argument equal to
"m / 2" instead of "m".
```

Anyways, it's little stuff like this that makes Coq both a joy (you need to program very carefully!) and a frustration (you didn't program carefully enough, and now what you want to prove is impossible!) to program in.

My 'programming flow' with Coq ends up being I state a theorem I want to prove, try to prove it, realize I need a lemma to prove it, try to prove that lemma, realize that the lemma is false, fiddle with the definitions a bit, get something that works a bit better, try again to prove the main theorem, backtrack to another lemma, walk away from the computer and come back with a breakthrough.

All you're trying to do is get the program to type-check ... but when it does, you're done, and not in a "I don't need to write unit tests because my types are so good" kind of way.  The type shows that the program works.  End of story.  (Modulo how much you trust the Coq verification system...)

## Why Lagrange's Theorem?

Lagrange's Theorem is a pretty basic result, but it's not a statement that's straightforward to prove with a proof assistant like Coq.  I'll given an informal discussion of the proof and talk about why I think this.

The standard proof is to define the concept of a _coset_ of a subgroup, which is basically all elements that result when you apply the subgroup to them $H$.   If your group is the additive integers mod 60 ($\mathbb{Z}_{60}$) (${0, 1, 2, \ldots}$), and your subgroup $H$ is $\mathbb{Z}_5$ (${0, 5, 10, \ldots}$), then the cosets of $H$ are ${[0], [1], [2], [3], [4]}$, where $[0]$ indicates all elements $a$ such that $a \in H$, $[1]$ is all elements $a$ such that $a - 1 \in H$, etc.

It turns out that given any subgroup $H$, its cosets form a partition of the whole group.  Here's a section from _A Book of Abstract Algebra_ (Charles C. Pinter; Dover Press)

<img class="img-responsive" style="max-width:520px" src="/images/counting-cosets.png" />

Each coset also ends up having the same size as the subgroup.  Following the above example, since $H$ has 12 elements, there are 12 elements in right coset of $[1]$ ($1, 6, 11, \ldots$).  Since the cosets partition the group (no element is in two cosets simultaneously) and each coset has the same size as the subgroup, the order of the subgroup must divide the group.

Easy.  However several of the concepts above don't translate easily to a theorem prover.  In order to reason about a finite partition, you must first teach the Coq what a partition of a finite set is.  You need to tell it that there's some enumeration of the list without duplicates.  Then you need to prove that the partition has the same size as the whole list.  You also need to define what a coset is, and provide some mechanism for computing the cosets for a given subgroup.  (Never mind that still you have to define what a group is - that's the easy stuff!)

## Representing Groups

I represented groups as a record-type in Coq (straightforward).

```coq
Structure Group : Type := makeGroup
{
  A :> Set;

  op : A -> A -> A ;
  inv : A -> A ;
  z : A ;

  op_assoc : forall a b c, op a (op b c) = op (op a b) c;
  op_z : forall a, op a z = a /\ op z a = a ;
  op_inverse : forall a, op a (inv a) = z /\ op (inv a) a = z
}.

Notation "x <*> y" := (op x y) (at level 50, left associativity).

(* This lets us prove some basic stuff like left/right cancellation *)

Lemma group_cancel_l: forall (a b c : G), a <*> b = a <*> c -> b = c.
Lemma group_cancel_r: forall (a b c :G), b <*> a = c <*> a -> b = c.

(* Left/right cancellation lets us show the identity is unique *)
Theorem id_is_unique: forall a : G, (forall b : G, a <*> b = b) -> a = z.
Proof
  intros a ADef.
  apply (group_cancel_r (inv a)).
  rewrite group_z_l; apply ADef.
Qed.
```

## Representing Subgroups and Cosets

Coq doesn't really do subtypes well; while in mathematics, a subgroup $H$ might be a subgroup $G$ there's no clear way to define a type $H$ as a subtype of $G$ and still prove everything you want.  I implemented both subgroups and cosets as sets via a characteristic functions.  A set $H$ if a function from the universe of group elements to the booleans, such that $a \in H$ iff $H a = true$.  This turned out to also be pretty straightforward.

```coq
Definition set (A : Set) := A -> bool.
Definition is_mem (A: Set) (H: set A) (a : A) := H a = true.

Structure subgroup (G : Group) : Type := makeSubgroup
{
  subgroup_mem :> set G;
  subgroup_z : is_mem subgroup_mem z;
  subgroup_closed : forall a b,
    is_mem subgroup_mem a /\  is_mem subgroup_mem b ->
    is_mem subgroup_mem (a <*> b);
  subgroup_inverse :
    forall a, is_mem subgroup_mem a -> is_mem subgroup_mem (inv a)
}.
```

With these set up I was able to define what a coset was (I used right cosets instead of left cosets) and prove that coset membership was equal to a certain kind of subgroup membership.  After this I was able to prove a bunch of results on cosets.

```coq
Definition right_coset (G: Group) (H: subgroup G) (a: G) : set G :=
  fun c => (subgroup_mem G H) (c <*> (inv a)).

Lemma coset_subgroup: forall a b  (H: subgroup G),
    is_mem (right_coset H b) a <-> is_mem H (a <*> inv b).
Proof.
  intros; unfold is_mem, right_coset.
  reflexivity.
Qed.
```

## Defining Finite Groups

Above I've defined a group, but we still need to define what _finite_ groups are.  This relies on the Coq notion of a `Listing`, which is an enumeration of a given type:

```coq
Print Listing.

Listing =
fun (A : Type) (l : list A) => NoDup l /\ Full l
     : forall A : Type, list A -> Prop

Print NoDup.

Inductive NoDup (A : Type) : list A -> Prop :=
    NoDup_nil : NoDup nil
  | NoDup_cons : forall (x : A) (l : list A), ~ List.In x l -> NoDup l -> NoDup (x :: l)


Print Full.

Full =
fun (A : Type) (l : list A) => forall a : A, List.In a l
     : forall A : Type, list A -> Prop
```

If `l` is a listing of type `A` we can construct a proof for any element `a : A` that `a` is a member of `l`.

Listings also can't have duplicate elements in them.  This is required to make our size argument - we can't really make arguments on the size of partitions of the group if you have repeated elements hanging around.

Next we need to define finite groups.  I'll just include the definitions, again they're relatively straightforward.

```coq
Structure finite_group := makeFiniteGroup
  {
    G :> Group;
    seq_g : list G;
    seq_listing : Listing seq_g;
  }.

Structure finite_subgroup (G: Group) := makeFiniteSubgroup
  {
    H :> subgroup G;
    subgroup_seq : list G;
    subgroup_seq_in : forall g, is_mem _ H g <-> In g subgroup_seq;
    subgroup_seq_nodup : NoDup subgroup_seq;
  }.
```

Before we get into the proof we also need an example of a finite group for some testing.  I went with the Klein 4-group.  The Klein 4-group ($V$) has 4 elements (the identity element $e$ and three others), and for all $x \in V, x^2 = e$.  It has 3 non-trivial subgroups - for each $x \in V, x \neq e$, ${e, x}$ is a subgroup.  Proving it's a group is fairly straightforward.

```coq
Inductive klein :=
  k_I | k_X | k_Y | k_Z.

Definition klein_op k1 k2 :=
  match (k1, k2) with
  | (k_I, _) => k2
  | (_, k_I) => k1
  | (k_X, k_X) => k_I
  | (k_X, k_Y) => k_Z
  | (k_X, k_Z) => k_Y
  | (k_Y, k_X) => k_Z
  | (k_Y, k_Y) => k_I
  | (k_Y, k_Z) => k_X
  | (k_Z, k_X) => k_Y
  | (k_Z, k_Y) => k_X
  | (k_Z, k_Z) => k_I
  end.

Definition klein_inv (k1: klein) := k1.

Lemma klein_double : forall k, klein_op k k = k_I.
  simple destruct k; [split; auto | auto | auto | auto].
Qed.

Definition klein_group : Group.
  apply (makeGroup klein klein_op klein_inv k_I).
  (* associativity *)
  - destruct a; destruct b; destruct c; compute; reflexivity.
  (* identity *)
  - destruct a; [split; auto | auto | auto | auto].
  (* inverse *)
  - intros; unfold klein_inv; rewrite klein_double; auto.
Defined.

Theorem klein_group_finite : finite_group.
Proof.
    apply (makeFiniteGroup klein_group [k_I; k_X; k_Y; k_Z]).
    ...
Qed.

(* Define the subgroup of the klein group containing itself and the identity *)
Definition klein_subgroup (k: klein_group) : subgroup klein_group.
  remember ((fun k' => match k' with
                         | k_I => true
                         | _ => klein_eq_dec k k'
                      end) : set klein_group) as char.
  apply (makeSubgroup _ char); auto.
  rewrite Heqchar; cbv; auto.
  (* closed under op *)
  destruct k in Heqchar; simple destruct a; simple destruct b;
    rewrite Heqchar; cbv; intros H; auto.
  (* closed under op: impossible cases *)
  0-36: destruct H; auto.
Defined.

Definition klein_subgroup_X := klein_subgroup k_X.
Definition klein_subgroup_Y := klein_subgroup k_Y.
Definition klein_subgroup_Z := klein_subgroup k_Z.
```

## How Can You Prove Length Equality In Coq?

Okay, cosets defined, subgroups defined, finiteness defined, time to rock this thing.  In order to prove the titular theorem I needed to set up two lists - the group, and the elements of the group arranged into cosets - and show that these have the same cardinality.  I also needed to set up the coset listing such that it was clear that the elements in a particular coset had the same size as the subgroup.

Coq actually doesn't provide a lot of out of the box mechanisms for showing that two lists are the same length.  I needed to set something up on my own - my primary approach was to set up a function that was injective between two non-duplicated lists, which allowed me to bound the size of the list.

```coq
(* FinFun's Injective and Surjective restricted to elements in a list *)

Definition ListInjective (A B: Type) (f: A -> B) (l: list A) :=
  (forall x y: A, In x l -> In y l -> f x = f y -> x = y).

Definition ListSurjective (A B: Type) (f: A -> B) (l: list B) (l': list A) :=
  (forall x: B, In x l -> exists y, In y l' /\ f y = x).

Definition ListIsomorphism (A B: Type) (f: A -> B) (l1: list A) (l2: list B) :=
  ListInjective f l1 /\
  ListSurjective f l2 l1 /\
  (forall d, In d l1 -> In (f d) l2).

(* If f is an injection from l1 into l2, l1 is at least as small as l2 *)
Lemma listinjective_NoDup_bounds_length (A B: Type):
  forall (l1: list A) (l2: list B) f,
    NoDup l1 ->
    NoDup l2 ->
    ListInjective f l1 ->
    (forall c, In c l1 -> In (f c) l2) ->
    length l1 <= length l2.

(* If f is a surjection from l1 into l2, l2 is at least as small as l1 *)
Lemma listsurjective_NoDup_bounds_length (A B: Type):
  forall (f: A -> B) l1 l2,
    NoDup l2 ->
    ListSurjective f l2 l1 ->
    length l2 <= length l1.

Lemma listisomorphism_NoDup_same_length (A B: Type):
  forall (f: A -> B) l1 l2,
    ListIsomorphism f l1 l2 ->
    NoDup l1 ->
    NoDup l2 ->
    length l1 = length l2.
```

I used the Coq [`FinFun`](https://coq.inria.fr/library/Coq.Logic.FinFun.html) package for a while before switching to my own definitions.  The reason I did this is because the standard library's `Injective` assumes an injection on an entire type, whereas I really only needed an injection restricted to a set of lists.

With this I was able to prove that any coset had the same cardinality as a subgroup, which involved showing `fun c => c <*> (inv g)` was an isomorphism from the coset of `g` into the subgroup `H`.

```coq
Definition finite_coset (G: finite_group) (H: subgroup G) g :=
  (filter (right_coset G H g) (seq_g G)).

Lemma finite_coset_same_size_as_subgroup (G: finite_group) (H: finite_subgroup G):
  forall g, length (finite_coset G H g) = cardinality_subgroup G H.
```

With that I made it past the 'easy' part of the proof into the more difficult part, which involved constructing a partition of the group by cosets.  This was incredibly difficult and I spent a lot of time on several approaches that ended up just not working.


The primary challenge is that I was trying to construct the partition in a way that chooses specific individual elements to serve as the "coset representatives" for their entire coset.  While this ended up working after a few failed attempts, but I spent a _lot_ of time going about this in ways that didn't end up working.

I had an inductive approach where I would use Coq's built-in partition function to slice the group listing between things in the head of the list and the rest of the sequence.

```coq
(* The goal of this function was to find the 'unique coset representatives'
   of a given subgroup.  The n argument was a way to bound induction to a
   certain number of steps so Coq doesn't complain about non-termination.

   I couldn't reasonably prove anything with this definition and so had to
   find a different approach. *)
Fixpoint unique_cosets_helper (G: finite_group) H (l: list G) n :=
  match n with
  | 0 => []
  | S m =>
    match l with
    | [] => []
    | a :: l' =>
      a :: (unique_cosets_helper G H (snd (partition (right_coset G H a) l')) m)
      end
    end.

Definition unique_cosets_did_not_work G H l := coset_reprs_helper G H l (length l).
```

Unfortunately I wasn't able to prove anything with this approach by itself.  I was missing a way to make sure that after processing `a`, there wasn't another element in the rest of the list such that `right_coset G H a = true`.

## Decidability of Equality

The main difficulty I ran into is that types in Coq don't come with define a notion of _equality_ - if you have two elements `x y: A`, you can't necessarily tell if they're equal or not without some sort of decision procedure.  For example, if `A` is functions from the natural numbers `nat -> nat`, determining if two functions `f` and `g` are equal requires checking all possible inputs, which won't ever terminate.

I'm not sure why I resisted adding a notation of equality for so long (I guess I just wanted to avoid adding "extra" things), but in retrospect, it's pretty clear that the proof needs it.  If you're creating a decision procedure to partition a finite set based on representatives, you kind of need to be able to tell if two elements are the same or different.

Equality decidability has the following type in Coq, which states that given two arguments `x` and `y`, there's either a proof that `x = y` or a proof that `x <> y`.

```coq
Definition eq_dec := forall (x y: A), {x = y} + {x <> y}.
```

It's straightforward to prove that the Klein group is decidable, since we can just have the proof checker try all possible forms of `x` and `y`:

```coq
Theorem klein_group_eq_decidable: eq_dec klein_group.
Proof.
  simple destruct x; simple destruct y; auto; right; discriminate.
Defined.
```

This allowed me to give a more natural definition of coset partitions, which allowed me to progress with the proof

```coq
Definition unique_cosets (G: finite_group) (H: subgroup G) (group_eq_dec: group_eq_decidable G) :=
fold_right
  (set_add group_eq_dec)
  (empty_set G)
  (map (canonical_right_coset G H) (seq_g G)).

(* Coset representatives of the subgroup {x, e} are {e, y} *)
Compute (unique_cosets klein_group_finite (klein_subgroup_X)) klein_group_eq_decidable.
     = [k_Y; k_I]
     : ListSet.set klein_group_finite
```

## Defining Partitions and Expanding Partitions By Representatives

Finally, I gave a definition of what it meant to partition a type `A`.  A partition is a list `l` and a function `f`, where `l` contains all members of the type `A` and `f` maps elements to their _partition representative_.  So, if an element `x` is in the partition of the element `a`, `f x = a`.

Partition representatives have the special property `f a = a`, which was needed to show a number of theorems.

```coq
Variable (A: Type).
(* Representative function for each element *)
Variable (f: A -> A).
Variable (l: list A).
(* Decidable equality is required *)
Variable eq_dec: forall (x y: A), {x = y} + {x <> y}.

Inductive fn_partition n :=
| fn_partition_intro:
    Listing l ->
    (* If an element is a representative, that element represents itself *)
    (forall x, In x (map f l) -> f x = x) ->
    (forall x,
        f x = x ->
        length (filter
            (fun y => if eq_dec (f y) x then true else false) l) = n) ->
    fn_partition n.
```

With this definition I was able to, given a partition, define an "expansion" of it with the base list, mapping each element of `l` into the pair `(f x, x)`.  This list ends up being unique and it's straightforward to show that it's in 1-1 correspondence with the listing.

```coq
(* partition representatives *)
Definition partition_reprs :=
    fold_right (set_add eq_dec) (empty_set A) (map f l).

(* partition elements for a given representative *)
Definition partition_elems a :=
    (filter (fun x => if eq_dec (f x) a then true else false) l).

(* the original list as pairs of elements with its partition representative *)
Definition expand_partition :=
  flat_map (fun x => list_prod [x] (partition_elems x)) partition_reprs.

(* Important results *)
Theorem expand_partition_isomorphism:
  Listing l ->
  ListIsomorphism snd expand_partition l.

Theorem expand_partition_length n:
  fn_partition n ->
  length expand_partition = length partition_reprs * n.
```

## Proving Lagrange's Theorem

Finally, now that I'd defined what a partition of a set was, given a finite group `G` with listing `l` it remained to define a function `f` on `l` that would, given a subgroup `H`, map each element of `G` into its partition representative.

Given an element `g`, the coset representative of the coset `H` is just the first element of the group listing that's in the coset.
```coq
(* Just take the first element in the listing that's in the coset *)
Definition coset_repr (G: finite_group) (H: subgroup G) g :=
  hd_error (filter (right_coset G H g) (seq_g G)).

Definition canonical_right_coset (G: finite_group) (H: subgroup G) g :=
  match coset_repr G H g with
  (* must supply this 'None' to type check even though it won't happen *)
  | None => g
  | Some a => a
  end.
```

This ends up being straightforward to show as a partition, which allows us to (finally) prove Lagrange's Theorem:

```coq
Theorem cosets_are_partition (G: finite_group) (H: finite_subgroup G) eq_dec:
  fn_partition G
               (canonical_right_coset G H)
               (seq_g G)
               eq_dec
               (cardinality_subgroup G H).

Theorem lagrange_theorem : forall (G: finite_group) (H: finite_subgroup G) group_eq_dec,
    length (unique_cosets G H group_eq_dec) * cardinality_subgroup G H =
    cardinality G.
```

Whew!  Group theory can finally rest easy, we now know Lagrange's Theorem is true (modulo the theoretical framework that Coq is based on being sound and the implementation not having any bugs that I've triggered in writing up my code).

## Conclusion

Everything seems pretty straightforward now that it's been completed.  However, I spent a lot of time on various rat-holes or trying to prove things that didn't end up being true in the end.  I'm not sure how I can do better at identifying a line of thinking as unfruitful or resulting in a contradiction beyond just getting more familiarity with the language.  Generally taking a step back and trying to think about things more generically helped me break through various problems I ran into along the way.

Of course, I'm not the first person to formalize this theorem in Coq.  Several proofs of it and more advanced group theory results exist, such as [Sylow's theorem](https://arxiv.org/abs/cs/0611057) (every group of order $p^{\alpha}m$ with $(p, m) = 1$ has a subgroup of order $p^{\alpha}$).  I'm likely to stop with Lagrange's Theorem but we'll see what I get up to next.
