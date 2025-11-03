// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "swiper/css"
import "swiper/css/pagination"
import ModalController from "./controllers/modal_controller"
application.register("modal", ModalController)
