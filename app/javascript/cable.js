// ActionCable setup
import consumer from "./channels/consumer"

// Make consumer available globally
window.App = window.App || {};
window.App.cable = consumer;
