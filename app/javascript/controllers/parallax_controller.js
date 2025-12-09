import { Controller } from "@hotwired/stimulus"

/*
  data-controller="parallax"
*/
export default class extends Controller {
  connect() {
    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    const scrolled = window.scrollY
    this.element.style.transform = `translateY(${scrolled * 0.1}px)`
  }
}
