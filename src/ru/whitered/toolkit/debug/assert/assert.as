package ru.whitered.toolkit.debug.assert 
{

	/**
	 * @author whitered
	 */
	public function assert(... args):void
	{
		/*FDT_IGNORE*/
		config::DEBUG 
		{
		/*FDT_IGNORE*/
			for each(var test:Boolean in args) if(!test) throw new AssertionError();
		/*FDT_IGNORE*/
		}
		/*FDT_IGNORE*/
	}
}
