import optparse

def args():
	seed=1
	iter=100
	parser = argparse.ArgumentParser(description='Monte Carlo generator some integers.')
	parser.add_argument('integers', metavar='N', type=int, nargs='+', help='an integer for the accumulator')
	parser.add_argument('--seed', dest='accumulate', action='store_const', const=sum, default=1, help='sum the integers (default: find the max)')	
	args = parser.parse_args()
	print(args.accumulate(args.integers))
