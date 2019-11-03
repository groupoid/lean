meta def enumeration : tactic unit :=
tactic.repeat
  (tactic.mk_const `or.inl >>= tactic.apply >>
   tactic.interactive.trivial <|>
   tactic.mk_const `or.inr >>= tactic.apply >> pure ())

namespace ground_zero.theorems.topology
universe u

structure topology (α : Type u) :=
(is_open : set (set α))
(empty_open : is_open ∅)
(full_open : is_open set.univ)
(inter_open : Π u v, is_open u → is_open v → is_open (u ∩ v))
(union_open : Π u v, is_open u → is_open v → is_open (u ∪ v))

def discrete (α : Type u) : topology α := begin
  fapply topology.mk, exact set.univ,
  repeat { intros, trivial }
end

theorem union.comm {α : Type u} (a b : set α) : a ∪ b = b ∪ a :=
begin funext x, apply propext, apply or.comm end

theorem inter.comm {α : Type u} (a b : set α) : a ∩ b = b ∩ a :=
begin funext x, apply propext, apply and.comm end

theorem union.empty {α : Type u} (a : set α) : a ∪ ∅ = a := begin
  funext x, apply propext, split,
  { intro h, cases h, exact h, cases h },
  { apply or.inl }
end

theorem inter.empty {α : Type u} (a : set α) : a ∩ ∅ = ∅ := begin
  funext x, apply propext, split; intro h,
  { cases h with a b, cases b },
  { cases h }
end

theorem union.univ {α : Type u} (a : set α) : a ∪ set.univ = set.univ := begin
  funext x, apply propext, split; intro h,
  { cases h; trivial },
  { apply or.inr, assumption }
end

theorem inter.univ {α : Type u} (a : set α) : a ∩ set.univ = a := begin
  funext x, apply propext, split; intro h,
  { cases h with n m, exact n },
  { split, exact h, trivial }
end

theorem union.id {α : Type u} (a : set α) : a ∪ a = a := begin
  funext x, apply propext, split,
  { intro h, cases h with a b, exact a, exact b },
  { intro h, apply or.inl, exact h }
end

theorem inter.id {α : Type u} (a : set α) : a ∩ a = a := begin
  funext x, apply propext, split,
  { intro h, cases h with a b, exact a },
  { intro h, split, repeat { exact h } }
end

def trivial.open (α : Type u) : set (set α) :=
λ h, h = ∅ ∨ h = set.univ

def trivial (α : Type u) : topology α := begin
  fapply topology.mk, exact trivial.open α,
  { apply or.inl, trivial },
  { apply or.inr, trivial },
  { intros u v a b,
    induction a; rw [a, inter.comm],
    { rw [inter.empty], apply or.inl, trivial },
    { rw [inter.univ], exact b } },
  { intros u v a b,
    induction a; rw [a, union.comm],
    { rw [union.empty], exact b },
    { rw [union.univ], apply or.inr, trivial } }
end

inductive X
| a | b | c | d

namespace X
  def τ : set (set X) :=
  { { a },
    { c },
    { a, c },
    { a, b, c },
    { a, d, c },
    ∅, set.univ }
end X

end ground_zero.theorems.topology