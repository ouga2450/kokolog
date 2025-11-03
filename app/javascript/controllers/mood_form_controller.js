import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details", "toggleIcon", "toggleLabel"]

  connect() {
    this.expanded = false
    this.hide()
  }

  toggle() {
    this.expanded ? this.hide() : this.show()
  }

  show() {
    this.detailsTarget.classList.remove("hidden")
    this.toggleIconTarget.textContent = "−"
    this.toggleLabelTarget.textContent = "閉じる"
    this.expanded = true
  }

  hide() {
    this.detailsTarget.classList.add("hidden")
    this.toggleIconTarget.textContent = "+"
    this.toggleLabelTarget.textContent = "詳細記録"
    this.expanded = false
  }
}
