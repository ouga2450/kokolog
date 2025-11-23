import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "amountField"]

  connect() {
    this.toggle()
  }

  toggle() {
    const type = this.typeSelectTarget.value
    const hide = type === "check_based" || type === ""

    this.amountFieldTarget.classList.toggle("hidden", hide)

    this.updateSwiperHeight()
  }

  getSwiper() {
    const swiperElem = this.element.closest(".swiper-slide")?.closest(".swiper")
    return swiperElem?.swiper || null
  }

  updateSwiperHeight() {
    console.log("updateSwiperHeight CALLED!")
    
    const swiper = this.getSwiper()
    console.log("swiper =", swiper)
    if (!swiper) return

    requestAnimationFrame(() => {
      swiper.updateAutoHeight()
      swiper.update()

      setTimeout(() => {
        swiper.updateAutoHeight()
        swiper.update()
      }, 20)
    })
  }
}
