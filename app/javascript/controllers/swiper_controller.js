// app/javascript/controllers/swiper_controller.js
import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"
import { Pagination } from "swiper/modules"

/**
 * data-controller="swiper"
 * data-swiper-target="container" … Swiper のルート要素（.swiper）
 * data-swiper-target="tab" … タブ切り替えボタン（任意個）
 * data-index="0" のように切り替え先スライド番号を保持
 */
export default class extends Controller {
  static targets = ["container", "tab"]

  connect() {
    this.instance = new Swiper(this.containerTarget, {
      modules: [Pagination],
      slidesPerView: 1,
      autoHeight: true,
      speed: 250,
      pagination: {
        el: this.containerTarget.querySelector(".swiper-pagination"),
        clickable: true,
      },
      on: {
        slideChange: () => this.syncTabs(),
      },
    })

    this.syncTabs()
  }

  disconnect() {
    if (this.instance) {
      this.instance.destroy(true, false)
      this.instance = null
    }
  }

  slideTo({ target }) {
    if (!this.instance || target.dataset.index === undefined) return
    this.instance.slideTo(Number(target.dataset.index))
  }

  syncTabs() {
    if (!this.hasTabTarget || !this.instance) return
    const activeIndex = this.instance.activeIndex

    this.tabTargets.forEach((tab, index) => {
      const isActive = index === activeIndex
      tab.toggleAttribute("aria-selected", isActive)
      tab.classList.toggle("tab-active", isActive)
    })
  }
}
