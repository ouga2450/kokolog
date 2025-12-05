import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details", "icon", "label"]
  static values = { default: String }

  connect() {
    // default-value="open" で展開
    if (this.defaultValue === "open") {
      this.expanded = true
      this.show()
    } else {
      this.expanded = false
      this.hide()
    }
  }

  toggle() {
    this.expanded ? this.hide() : this.show()
  }

  show() {
    this.detailsTarget.classList.remove("hidden")

    if (this.hasIconTarget) {
      this.iconTarget.textContent =
        this.data.get("iconClose") || "−"
    }

    if (this.hasLabelTarget) {
      this.labelTarget.textContent =
        this.data.get("labelClose") || "閉じる"
    }

    this.expanded = true
  }

  hide() {
    this.detailsTarget.classList.add("hidden")

    if (this.hasIconTarget) {
      this.iconTarget.textContent =
        this.data.get("iconOpen") || "+"
    }

    if (this.hasLabelTarget) {
      this.labelTarget.textContent =
        this.data.get("labelOpen") || "詳細記録"
    }

    this.expanded = false
  }
}
