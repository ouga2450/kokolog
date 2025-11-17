import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "pane"]

  connect() {
    this.showPane(0)
  }

  show(event) {
    const index = Number(event.currentTarget.dataset.index)
    this.showPane(index)
  }

  showPane(index) {
    this.tabTargets.forEach((tab, i) => {
      const active = i === index
      tab.classList.toggle("btn", active)
      tab.classList.toggle("btn-primary", active)
      tab.classList.toggle("text-base-content/60", !active)
    })

    this.paneTargets.forEach((pane, i) => {
      pane.classList.toggle("hidden", i !== index)
    })
  }
}
