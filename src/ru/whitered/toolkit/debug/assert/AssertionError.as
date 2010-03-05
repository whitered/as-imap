package ru.whitered.toolkit.debug.assert 
{

	/**
	 * @author whitered
	 */
	public class AssertionError extends Error 
	{
		public function AssertionError()
		{
			super("Assertion error");
		}
	}
}
