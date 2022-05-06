'use babel';
import { CompositeDisposable } from 'atom';

export default {
	eventListener: null,
	subscriptions: null,
	eventType: 'click',
	eventTypeLabel: 'left-click',
	eventTypes: ['left-click','alt+left-click','middle-click'],

	// default methods
	activate(state) {
		// create event eventListener
		this.createEventListener()

		// Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
		this.subscriptions = new CompositeDisposable()

		// Add config options
		this.subscriptions.add(
			atom.config.observe('click-bookmarks.eventType', (eventTypeLabel) => {
				this.removeEventListener()
				this.setEventType(eventTypeLabel)
				this.createEventListener()
			})
		);

		// Register commands
		this.subscriptions.add(atom.commands.add('atom-workspace', {
			'click-bookmarks:toggle-event-type': () => this.toggleEventType()
		}));
	},

	deactivate() {
		this.subscriptions.dispose()
		this.removeEventListener()
	},

	// helpers
	setEventType(eventTypeLabel){
		this.eventType = 'middle-click' == eventTypeLabel ? 'auxclick':'click'
		this.eventTypeLabel = eventTypeLabel
	},

	// event listener methods
	createEventListener() {
		var eventTypeLabel = this.eventTypeLabel

		// create event listener
		this.eventListener = function(event) {
			// middle click event check
			if(
				('middle-click' == eventTypeLabel)
				&& (event.button != 1)
			) return
			// alt click event check
			else if(
				('alt+left-click' == eventTypeLabel)
				&& (!event.altKey)
			) return
			// click event check
			else if(
				('left-click' == eventTypeLabel)
				&& (event.altKey)
			) return

			// get current editor
			let editor = atom.workspace.getActiveTextEditor()
			if(!editor) return

			// get line number gutter
			let gutter = editor.gutterWithName('line-number')
			if(!gutter) return

			// get target line
			let targetLine = event.target;

			// check if it's a child element
			if(!targetLine.classList.contains('line-number')){
				if(!targetLine || typeof targetLine === 'undefined') return
				let targetLine = targetLine.closest('.line-number')

				// disallow clicking icon for foldable items
				if(!targetLine || targetLine.classList.contains('foldable')) return
			}
			if(!targetLine.classList.contains('line-number')) return

			// get target gutter
			let targetGutter = targetLine.closest('.gutter')
			if(!targetGutter) return

			// see if gutter matches the target gutter
			if(gutter.element == targetGutter){
				// move to clicked row
				let row = parseInt(targetLine.textContent) - 1;
				editor.setCursorBufferPosition([row,0])

				// toggle bookmark for the event target (part of core bookmarks package)
				atom.commands.dispatch(targetLine, 'bookmarks:toggle-bookmark');

				// log
				// console.log('dispatched',event,targetLine,targetGutter);
			}
		}

		// add event listener
		atom.workspace.activePaneContainer.paneContainer.element.addEventListener(this.eventType,this.eventListener)
	},

	removeEventListener() {
		// remove click event
		atom.workspace.activePaneContainer.paneContainer.element.removeEventListener(this.eventType,this.eventListener)

		// reset eventListener
		this.eventListener = null
	},

	// commands
	toggleEventType(type = null){
		// default
		if(null == type){
			// get current type and types
			let currentType = atom.config.get("click-bookmarks.eventType")
			let types = this.eventTypes
			let i = types.indexOf(currentType)

			// step to next
			if(i >= 0 && i < types.length - 1) type = types[i + 1]
			else type = types[0]
		}

		// update
		atom.config.set("click-bookmarks.eventType", type)

		// log
		atom.notifications.addInfo('Click Bookmarks Event Type changed to ' + type + '!')
		// console.log('EventType was toggled!')
	}
};
