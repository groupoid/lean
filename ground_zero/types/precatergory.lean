import ground_zero.HITs.graph ground_zero.HITs.interval
open ground_zero.HITs ground_zero.types ground_zero.theorems.functions
open ground_zero.HITs.interval ground_zero.types.equiv ground_zero.structures

hott theory

namespace ground_zero.types
universes u v

structure precategory (α : Sort u) :=
(hom : α → α → Sort v)
(id {a : α} : hom a a)
(comp {a b c : α} : hom b c → hom a b → hom a c)
(infix ∘ := comp)
(id_left {a b : α} : Π (f : hom a b), f = id ∘ f)
(id_right {a b : α} : Π (f : hom a b), f = f ∘ id)
(assoc {a b c d : α} : Π (f : hom a b) (g : hom b c) (h : hom c d),
  h ∘ (g ∘ f) = (h ∘ g) ∘ f)

namespace precategory
  def cat_graph {α : Sort u} (𝒞 : precategory α) := graph (hom 𝒞)

  def compose {α : Sort u} {𝒞 : precategory α} {a b c : α}
    (g : hom 𝒞 b c) (f : hom 𝒞 a b) : hom 𝒞 a c := 𝒞.comp g f
  local infix ∘ := compose

  def op {α : Sort u} (𝒞 : precategory α) : precategory α :=
  { hom := λ a b, hom 𝒞 b a,
    id := 𝒞.id,
    comp := λ a b c p q, 𝒞.comp q p,
    id_left := λ a b p, 𝒞.id_right p,
    id_right := λ a b p, 𝒞.id_left p,
    assoc := λ a b c d f g h, (𝒞.assoc h g f)⁻¹ }

  postfix `ᵒᵖ`:1025 := op

  def Path (α : Sort u) : precategory α :=
  { hom := (=),
    id := ground_zero.types.eq.refl,
    comp := λ a b c p q, q ⬝ p,
    id_left := λ a b p, (eq.refl_right p)⁻¹,
    id_right := λ a b p, (eq.refl_left p)⁻¹,
    assoc := λ a b c d f g h, (eq.assoc f g h)⁻¹ }

  def Top : precategory (Sort u) :=
  { hom := (→),
    id := @idfun,
    comp := @function.comp,
    id_left := λ a b f, funext (homotopy.id f),
    id_right := λ a b f, funext (homotopy.id f),
    assoc := λ a b c d f g h, eq.rfl }

  def sigma_unique {α : Sort u} (π : α → Sort v) :=
  Σ' x, (π x) × (Π y, π y → y = x)
  notation `Σ!` binders `, ` r:(scoped P, sigma_unique P) := r

  structure product {α : Sort u} (𝒞 : precategory α) (X₁ X₂ : α) :=
  (X : α) (π₁ : hom 𝒞 X X₁) (π₂ : hom 𝒞 X X₂)
  (canonicity : Π (Y : α) (f₁ : hom 𝒞 Y X₁) (f₂ : hom 𝒞 Y X₂),
    Σ! (f : hom 𝒞 Y X), π₁ ∘ f = f₁ × π₂ ∘ f = f₂)

  def coproduct {α : Sort u} (𝒞 : precategory α) (X₁ X₂ : α) :=
  product 𝒞ᵒᵖ X₁ X₂
end precategory

end ground_zero.types