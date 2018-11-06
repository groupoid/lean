import ground_zero.structures ground_zero.support
open ground_zero.structures

namespace ground_zero

def {u} trunc (α : Sort u) := @quot α (λ _ _, true)
notation `∥` α `∥` := trunc α

namespace trunc
  universes u v

  private def const_rel {α : Sort u} : α → α → Prop :=
  λ _ _, true

  def elem {α : Sort u} : α → ∥α∥ :=
  quot.mk const_rel
  notation `|` a `|` := elem a

  def rec {α : Sort u} {β : Sort v} [prop β]
    (f : α → β) : trunc α → β :=
  @quot.lift α const_rel β f
  (λ a b _, support.truncation $ prop.intro (f a) (f b))

  @[recursor] def ind {α : Sort u} {π : ∥α∥ → Prop}
    (f : Π (a : α), π (trunc.elem a)) : Π (x : ∥α∥), π x :=
  @quot.ind α const_rel π f

  def uniq {α : Type u} (a b : ∥α∥) : a = b :> ∥α∥ := begin
    apply support.inclusion,
    induction a, induction b,
    apply (@quot.sound α const_rel a b true.intro),
    repeat { trivial }
  end
  instance {α : Type u} : prop ∥α∥ := ⟨trunc.uniq⟩

  def extract {α : Type u} [prop α] : ∥α∥ → α :=
  trunc.rec id

  def lift {α β : Type u} (f : α → β) : ∥α∥ → ∥β∥ :=
  trunc.rec (elem ∘ f)

  theorem equiv_iff_trunc {α β : Type u}
    (f : α → β) (g : β → α) : ∥α∥ ≃ ∥β∥ := begin
    existsi lift f, split; existsi lift g;
    { intro x, apply uniq }
  end

end trunc

end ground_zero