import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.itemTargets.forEach((el) => {
      el.classList.add(
        "opacity-0",
        "translate-y-8",
        "transition-all",
        "duration-700",
        "ease-out"
      )
    })

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.remove("opacity-0", "translate-y-8")
            entry.target.classList.add("opacity-100", "translate-y-0")
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15 }
    )

    this.itemTargets.forEach((el) => this.observer.observe(el))
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
