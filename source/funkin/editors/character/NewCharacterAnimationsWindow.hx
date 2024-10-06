package funkin.editors.character;

class NewCharacterAnimationsWindow extends UIWindow {

	public var animDropdown:UIDropDown;
	public var addButton:UIButton;
	public var editButton:UIButton;

	public function new(x:Int, y:Int, width:Int, height:Int, title:String, animations:Array<String>) {
		super(x, y, width, height, title);
		animDropdown = new UIDropDown(this.x + 15, this.y + 50, width - 10, 32, animations);
		this.members.push(animDropdown);

		addButton = new UIButton(animDropdown.x, animDropdown.y + 50, "Add Animation", null, Std.int(animDropdown.bWidth / 2));
		this.members.push(addButton);
		editButton = new UIButton(addButton.x + addButton.bWidth + 10, addButton.y, "Edit Animation", null, addButton.bWidth);
		this.members.push(editButton);
	}
}