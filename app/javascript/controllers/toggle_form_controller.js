import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details", "icon", "label"]

  connect() {
    this.expanded = false
    this.hide()
  }

  toggle() {
    this.expanded ? this.hide() : this.show()
  }

  show() {
    this.detailsTarget.classList.remove("hidden")

    // アイコン
    if (this.hasIconTarget) {
      this.iconTarget.textContent = this.data.get("iconClose") || "−"
    }

    // ラベル
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.data.get("labelClose") || "閉じる"
    }

    this.expanded = true
  }

  hide() {
    this.detailsTarget.classList.add("hidden")

    // アイコン
    if (this.hasIconTarget) {
      this.iconTarget.textContent = this.data.get("iconOpen") || "+"
    }

    // ラベル
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.data.get("labelOpen") || "詳細記録"
    }

    this.expanded = false
  }
}
