import ground_zero.cubical.cubes
open ground_zero.cubical ground_zero.types ground_zero.HITs
open ground_zero.HITs.interval (i₀ i₁)

/-
  * Coercions.
  * Basic path lemmas: refl, symm, cong, funext...
  * Connections.
  * Singleton contractibility, J elimination rule.
  * PathP.
-/

namespace ground_zero.cubical

namespace Path
universes u v

def coe.forward (π : I → Type u) (i : I) (x : π i₀) : π i :=
interval.ind x (equiv.subst interval.seg x) (equiv.path_over_subst eq.rfl) i

def coe.back (π : I → Type u) (i : I) (x : π i₁) : π i :=
interval.ind (equiv.subst interval.seg⁻¹ x) x (begin
  apply equiv.path_over_subst, transitivity,
  { symmetry, apply equiv.subst_comp }, transitivity,
  { apply eq.map (λ p, equiv.subst p x), apply eq.inv_comp },
  reflexivity
end) i

def coe (i k : I) (π : I → Type u) : π i → π k :=
coe.forward (λ i, π i → π k) i (coe.forward π k)

def coe_inv (i k : I) (π : I → Type u) : π i → π k :=
coe.back (λ i, π i → π k) i (coe.back π k)

notation `coe⁻¹` := coe_inv

@[refl] def refl {α : Type u} (a : α) : a ⇝ a := <i> a
def rfl {α : Type u} {a : α} : a ⇝ a := <i> a

@[symm] def symm {α : Type u} {a b : α} (p : a ⇝ b) : b ⇝ a :=
coe 1 0 (λ i, b ⇝ p # i) rfl
postfix `⁻¹` := symm

def seg : i₀ ⇝ i₁ := <i> i

def neg (x : I) : I := seg⁻¹ # x
prefix `−`:30 := neg

abbreviation inv {α : Type u} {a b : α} (p : a ⇝ b) := p⁻¹

example {α : Type u} {a b : α} (p : a ⇝ b) : b ⇝ a :=
<i> p # −i

def homotopy {α : Type u} {π : α → Type v} (f g : Π (x : α), π x) :=
Π (x : α), f x ⇝ g x
infix ` ~' `:50 := homotopy

def homotopy_equality {α : Type u} {π : α → Type v} {f g : Π (x : α), π x}
  (p : f ~' g) : f ~ g :=
λ x, to_equality (p x)

def funext {α : Type u} {β : α → Type v} {f g : Π (x : α), β x}
  (p : f ~' g) : f ⇝ g :=
<i> λ x, p x # i

def cong {α : Type u} {β : Type v} {a b : α}
  (f : α → β) (p : a ⇝ b) : f a ⇝ f b :=
<i> f (p # i)

def ap {α : Type u} {β : α → Type v} {a b : α}
  (f : α → β a) (p : a ⇝ b) : f a ⇝ f b :=
<i> f (p # i)

def subst {α : Type u} {π : α → Type v} {a b : α}
  (p : a ⇝ b) (x : π a) : π b :=
coe 0 1 (λ i, π (p # i)) x

abbreviation transport {α : Type u} (π : α → Type v) {a b : α}
  (p : a ⇝ b) : π a → π b := subst p

def trans {α β : Type u} (p : α ⇝ β) : α → β :=
coe 0 1 (λ i, p # i)
abbreviation coerce {α β : Type u} : (α ⇝ β) → (α → β) := trans

def trans_neg {α β : Type u} (p : α ⇝ β) : β → α :=
coe 1 0 (λ i, p # i)

def trans_back {α β : Type u} (p : α ⇝ β) : α → β :=
coe⁻¹ 0 1 (λ i, p # i)

notation `trans⁻¹` := trans_back

def transK {α β : Type u} (p : α ⇝ β) (x : α) :
  x ⇝ trans_neg p (trans p x) :=
<i> coe i 0 (λ i, p # i) (coe 0 i (λ i, p # i) x)

def idtoeqv {α β : Type u} (p : α ⇝ β) : α ≃ β :=
trans (<i> α ≃ p # i) (equiv.id α)

def test_eta {α : Type u} {a b : α} (p : a ⇝ b) : p ⇝ p := rfl
def face₀ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # 0
def face₁ {α : Type u} {a b : α} (p : a ⇝ b) : α := p # 1

def comp_test₀ {α : Type u} {a b : α} (p : a ⇝ b) : p # 0 ⇝ a := rfl
def comp_test₁ {α : Type u} {a b : α} (p : a ⇝ b) : p # 1 ⇝ b := rfl

-- fail
--def symm_test {α : Type u} {a b : α} (p : a ⇝ b) : (p⁻¹)⁻¹ ⇝ p := rfl
@[trans] def composition {α : Type u} {a b c : α}
  (p : a ⇝ b) (q : b ⇝ c) : a ⇝ c := subst q p

infix ⬝ := composition

-- this will be replaced by a more general version in future
def kan {α : Type u} {a b c d : α}
  (bottom : b ⇝ c) (left : b ⇝ a) (right : c ⇝ d) : a ⇝ d :=
left⁻¹ ⬝ bottom ⬝ right

def kan_op {α : Type u} {a b : α} (p : a ⇝ a) (q : a ⇝ b) : b ⇝ b :=
kan p q q

def interval_contr_left (i : I) : i₀ ⇝ i := coe 0 i (λ i, i₀ ⇝ i) rfl
def interval_contr_right (i : I) : i₁ ⇝ i := coe 1 i (λ i, i₁ ⇝ i) rfl

def seg_path : i₀ ⇝ i₁ := interval_contr_left i₁

-- or too direct way
example : i₀ ⇝ i₁ := <i> i

def conn_and {α : Type u} {a b : α} (p : a ⇝ b) :
  LineP (λ i, a ⇝ p # i) :=
λ i, <j> p # i ∧ j

def neg_neg (x : I) : neg (neg x) ⇝ x :=
(conn_and seg⁻¹ $ neg x)⁻¹ ⬝ interval_contr_right x

def conn_or {α : Type u} {a b : α} (p : a ⇝ b) :
  LineP (λ i, p # i ⇝ b) :=
λ i, <j> p # i ∨ j

def singl {α : Type u} (a : α) :=
Σ (x : α), a ⇝ x

def eta {α : Type u} (a : α) : singl a := ⟨a, refl a⟩

def refl_contr {α : Type u} {a b : α} (p : a ⇝ b) :
  LineP (λ i, a ⇝ p # i) :=
interval.hrec _ (refl a) p (begin
  cases p with f, unfold refl,
  apply heq.map, funext,
  refine interval.prop_rec _ _ i,
  { reflexivity },
  { apply ground_zero.support.truncation,
    apply eq.map, exact interval.seg }
end)

/-
This doesn’t pass typechecking.

def J {α : Type u} {a : α} {π : Π (b : α), a ⇝ b → Type u}
  (h : π a (refl a)) (b : α) (p : a ⇝ b) : π b (<i> p # i) :=
coe (λ i, π (p # i) (conn_and p i)) h i₁

def J {α : Type u} {a : α} {π : Π (b : α), a ⇝ b → Type u}
  (h : π a (refl a)) (b : α) (p : a ⇝ b) : π b (<i> p # i) :=
transport (<i> π (p # i) (<j> p # i ∧ j)) h
-/

def J {α : Type u} {a : α} (π : Π (b : α), a ⇝ b → Type v)
  (h : π a (refl a)) {b : α} (p : a ⇝ b) : π b p :=
trans (<i> π (p # i) (refl_contr p i)) h

end Path

def {u} PathP (σ : I → Type u) (a : σ 0) (b : σ 1) :=
Path (equiv.subst interval.seg a) b

def {u} PathP.lam (σ : I → Type u) (f : Π i, σ i) : PathP σ (f 0) (f 1) :=
Path.lam (interval.rec _ _ (equiv.apd f interval.seg))

end ground_zero.cubical