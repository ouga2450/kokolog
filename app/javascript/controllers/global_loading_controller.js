import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.overlay = document.getElementById("global-loading")

    this.show = this.show.bind(this)
    this.hide = this.hide.bind(this)

    document.addEventListener("turbo:visit", this.show)
    document.addEventListener("turbo:submit-start", this.show)

    document.addEventListener("turbo:load", this.hide)
    document.addEventListener("turbo:submit-end", this.hide)
  }

  // 表示は1回だけ
  show() {
    if (!this.overlay || this.startedAt) return

    this.startedAt = Date.now()
    this.overlay.classList.remove("hidden")

    // フェードインが確実に走るように1フレーム待つ
    requestAnimationFrame(() => {
      this.overlay.classList.remove("opacity-0")
      this.overlay.classList.add("opacity-100")
    })
  }

  hide() {
    if (!this.overlay || !this.startedAt) return

    const elapsed = Date.now() - this.startedAt
    const remaining = this.minDuration - elapsed

    if (remaining > 0) {
      setTimeout(() => this._hideNow(), remaining)
    } else {
      this._hideNow()
    }
  }

  _hideNow() {
    // フェードアウト
    this.overlay.classList.remove("opacity-100")
    this.overlay.classList.add("opacity-0")

    setTimeout(() => {
      this.overlay.classList.add("hidden")
      this.startedAt = null
    }, 300) // CSSのtransition時間と合わせる
  }
}
