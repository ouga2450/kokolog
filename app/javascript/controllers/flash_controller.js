import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // データ取得、コントローラでValueを使う場合はstaticで定義する
  static values = {
    timeout: Number
  }

  static targets = ["container"]

  connect() {
    setTimeout(() => {
      this.fadeOut()
    }, this.timeoutValue || 3000)
  }

  fadeOut() {
    const el = this.containerTarget
    el.style.opacity = "0"

    setTimeout(() => {
      el.remove()
    }, 500)
  }
}
