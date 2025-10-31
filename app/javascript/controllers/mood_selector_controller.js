import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mood-selector"
export default class extends Controller {
  static targets = ["button", "slider"]

  connect() {
    console.log("✅ mood-selector connected!")
    this.updateActiveState(this.normalizeIndex(this.sliderTarget?.value ?? 2))
  }

  // 絵文字ボタン選択
  select(event) {
    const index = this.normalizeIndex(
      event.currentTarget.dataset.moodSelectorIndexValue
    )
    this.updateActiveState(index)
  }

  // スライダー操作
  slide(event) {
    const index = this.normalizeIndex(event.target.value)
    this.updateActiveState(index)
  }

  // 選択状態の更新
  updateActiveState(activeIndex) {
    if (this.hasSliderTarget) {
      this.sliderTarget.value = activeIndex
    }

    this.buttonTargets.forEach((btn, i) => {
      const isActive = i === activeIndex

      btn.classList.toggle("bg-primary", isActive)
      btn.classList.toggle("text-white", isActive)
      btn.classList.toggle("border-primary", isActive)
      btn.classList.toggle("shadow-md", isActive)
      btn.classList.toggle("scale-105", isActive)
      btn.classList.toggle("bg-base-200", !isActive)
      btn.setAttribute("aria-pressed", isActive)
    })
  }

  normalizeIndex(value) {
    const index = Number.parseInt(value, 10)

    if (Number.isNaN(index)) {
      return 0
    }

    const maxIndex = this.buttonTargets.length - 1

    return Math.min(Math.max(index, 0), maxIndex)
  }
}
