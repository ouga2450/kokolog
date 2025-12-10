import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { prevUrl: String, nextUrl: String }

  connect() {
    this.startX = 0
    this.animating = false
  }

  touchstart(event) {
    if (this.animating) return
    this.startX = event.touches[0].clientX
  }

  touchend(event) {
    if (this.animating) return

    const endX = event.changedTouches[0].clientX
    const diff = endX - this.startX

    if (Math.abs(diff) < 40) return // 誤作動防止

    if (diff > 0) {
      // 右スワイプ → 前月へ
      this.animate("right")
      setTimeout(() => Turbo.visit(this.prevUrlValue), 180)
    } else {
      // 左スワイプ → 次月へ
      this.animate("left")
      setTimeout(() => Turbo.visit(this.nextUrlValue), 180)
    }
  }

  animate(direction) {
    this.animating = true
    const wrapper = this.element.querySelector(".calendar-wrapper")
    if (!wrapper) return

    // transition 設定
    wrapper.classList.add("transition", "duration-200", "ease-out")

    // スライド & フェード（Tailwind クラスのみ）
    if (direction === "left") {
      wrapper.classList.add("-translate-x-4", "opacity-0")
    } else {
      wrapper.classList.add("translate-x-4", "opacity-0")
    }
  }
}
