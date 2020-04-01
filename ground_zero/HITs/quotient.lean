import ground_zero.HITs.trunc ground_zero.HITs.graph
open ground_zero.structures (propset hset zero_eqv_set)
open ground_zero.theorems (funext)

namespace ground_zero.HITs
universes u v w

hott theory

def quot {α : Type u} (R : α → α → propset.{v}) := ∥graph (λ x y, (R x y).fst)∥₀

section
  variables {α : Type u} (R : α → α → propset.{v})

  def reflexive  := Π a, (R a a).fst
  def symmetric  := Π a b, (R a b).fst → (R b a).fst
  def transitive := Π a b c, (R a b).fst → (R b c).fst → (R a c).fst

  def equivalence := reflexive R × symmetric R × transitive R
end

structure setoid (α : Type u) :=
(rel : α → α → propset.{v}) (iseqv : equivalence rel)

@[hott] def setoid.prod {α : Type u} {x y : α → α → propset.{v}}
  {h : equivalence x} {g : equivalence y}
  (p : x = y) (q : h =[p] g) : ⟨x, h⟩ = ⟨y, g⟩ :> setoid α :=
begin induction p, induction q, trivial end

@[hott] def eqv_prop {α : Type u} {rel : α → α → propset.{v}}
  (h g : equivalence rel) : h = g := begin
  apply ground_zero.structures.product_prop,
  { intros f g, apply ground_zero.theorems.funext, intro x,
    apply (rel x x).snd },
  apply ground_zero.structures.product_prop;
  { intros f g, repeat { apply ground_zero.theorems.funext, intro },
    apply (rel _ _).snd }
end

@[hott] def setoid.eq {α : Type u} : Π {x y : setoid α}, x.rel = y.rel → x = y
| ⟨x, _⟩ ⟨y, _⟩ p := setoid.prod p (eqv_prop _ _)

def quotient {α : Type u} (s : setoid α) := quot s.rel

@[hott] def quotient.elem {α : Type u} {s : setoid α} : α → quotient s :=
trunc.elem ∘ graph.elem

@[hott] def setoid.apply {α : Type u} (s : setoid α) (a b : α) : Type v := (s.rel a b).fst

@[hott] def quotient.sound {α : Type u} {s : setoid α} {a b : α} :
  s.apply a b → quotient.elem a = quotient.elem b := begin
  intro H, apply ground_zero.types.eq.map trunc.elem,
  apply graph.line, assumption
end

@[hott] def quotient.ind {α : Type u} {s : setoid α} {π : quotient s → Type v}
  (elemπ : Π x, π (quotient.elem x))
  (lineπ : Π x y H, elemπ x =[quotient.sound H] elemπ y)
  (set   : Π x, hset (π x)) : Π x, π x := begin
  fapply trunc.ind,
  { fapply graph.ind, apply elemπ,
    { intros x y H, apply ground_zero.types.eq.trans,
      apply ground_zero.types.equiv.transport_comp,
      apply lineπ } },
  { intro x, apply zero_eqv_set.left, apply set }
end

@[hott] def quotient.rec {α : Type u} {β : Type v} {s : setoid α}
  (elemπ : α → β)
  (lineπ : Π x y, s.apply x y → elemπ x = elemπ y)
  (set   : hset β) : quotient s → β :=
@quotient.ind α s (λ _, β) elemπ
  (λ x y H, ground_zero.types.equiv.pathover_of_eq (quotient.sound H) (lineπ x y H))
  (λ _ _ _, set)

end ground_zero.HITs