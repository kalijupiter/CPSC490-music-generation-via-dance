import socket
import oscpy.client as osc
import time
from collections import deque

# define IP address and port to listen to
UDP_IP = "172.29.33.198"
UDP_PORT = 8092

# class for maintaining and retrieving the moving average of each stream of data
class MovingAverage:
    def __init__(self, size):
        self.size = size
        self.data = deque(maxlen=size)
        self.sum = 0.0
        self.avg = 0.0
        self.prev = 400.0
        self.vel = 0.0

    def add_data_point(self, new_data_point):
        if len(self.data) == self.size:
            self.sum -= self.data[0]
        self.data.append(new_data_point)
        self.sum += new_data_point
        self.avg = self.sum / len(self.data)

        if self.prev == 400.0:
            self.prev = new_data_point
        else:
            self.vel = (new_data_point - self.prev) / 0.1
            self.prev = new_data_point

    def get_moving_average(self):
        return round(self.avg, 2)
    
    def get_velocity(self):
        return round(self.vel, 2)

# initialize socket
sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

# Set up OSC client
client = osc.OSCClient('127.0.0.1', 6448)  # Assuming Wekinator is running locally on default port 6448

# string of three moving averages, one for each stream of data
cleaned_data = [MovingAverage(5) for i in range(3)]

# Define the interval between data sending
interval = 0.1  # in seconds

while True:
    # retreive data and split into individual streams
    data, addr = sock.recvfrom(1024)
    vals = [float(i) for i in data.decode("ASCII").split()]

    #assign each point to its respective moving average, and update that point
    cleaned_vals = [0, 0, 0]
    for n in range(3):
        cleaned_data[n].add_data_point(vals[n])
        cleaned_vals[n] = cleaned_data[n].get_moving_average()

    #send data to wekinator    
    client.send_message(b'/wek/inputs', cleaned_vals)
    time.sleep(interval)
    vals = []
    cleaned_vals = []

    
