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

      // アクセシビリティ対応
      tab.toggleAttribute("aria-selected", isActive)
      tab.setAttribute("tabindex", isActive ? "0" : "-1")

      // --- active（DaisyUI]） ---
      tab.classList.toggle("btn", isActive)
      tab.classList.toggle("btn-primary", isActive)
      tab.classList.toggle("btn-sm", isActive)

      // --- inactive（薄い文字だけ） ---
      tab.classList.toggle("text-base-content/50", !isActive)

      // DaisyUI tab 系クラスは使わないので削除
      tab.classList.remove("tab-active")
    })
  }
}
